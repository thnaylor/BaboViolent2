/*
	Copyright 2012 bitHeads inc.

	This file is part of the BaboViolent 2 source code.

	The BaboViolent 2 source code is free software: you can redistribute it and/or 
	modify it under the terms of the GNU General Public License as published by the 
	Free Software Foundation, either version 3 of the License, or (at your option) 
	any later version.

	The BaboViolent 2 source code is distributed in the hope that it will be useful, 
	but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
	FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License along with the 
	BaboViolent 2 source code. If not, see http://www.gnu.org/licenses/.
*/

/* TCE (c) All rights reserved */


#include "BrebisGL.h"
#include "dkwi.h"
#include "imgui.h"
#include "imgui_impl_sdl.h"
#include "imgui_impl_opengl3.h"
#include <SDL.h>
#include <string>
#include "dki.h"

static std::string last_error = "";
static SDL_Window* window = nullptr;
static SDL_GLContext gl_context = nullptr;
static bool done = true;
static CMainLoopInterface *mainLoopObject = nullptr;

#ifndef DEDICATED_SERVER
class Writting;
extern Writting * writting;

// Windows-style Alt + numeric keypad (or top-row digits): hold Alt, type 0155, release Alt ? char 155.
static int s_altcodeValue = -2; // -2 idle; -1 Alt down, no digits yet; >= 0 accumulating decimal
static bool s_skipNextSingleDigitTextinput = false;

static int dkw_keycode_to_digit(SDL_Keycode sym)
{
	if (sym >= SDLK_KP_1 && sym <= SDLK_KP_9)
		return (int)(sym - SDLK_KP_1 + 1);
	if (sym == SDLK_KP_0)
		return 0;
	if (sym >= SDLK_0 && sym <= SDLK_9)
		return (int)(sym - SDLK_0);
	return -1;
}

static bool dkw_mod_alt_for_codes()
{
	const SDL_Keymod m = SDL_GetModState();
	if ((m & KMOD_ALT) != 0)
		return true;
	// AltGr (e.g. many European layouts): Ctrl + right Alt
	if ((m & KMOD_CTRL) != 0 && (m & KMOD_RALT) != 0)
		return true;
	if ((m & KMOD_MODE) != 0)
		return true;
	return false;
}

// UTF-8 from SDL_TEXTINPUT -> Unicode code points for Writting::writeText
static void dkwSendTextUtf8(const char *text)
{
	if (!mainLoopObject || !text)
		return;
	if (s_skipNextSingleDigitTextinput && (unsigned char)text[0] >= '0' && (unsigned char)text[0] <= '9' && text[1] == '\0')
	{
		s_skipNextSingleDigitTextinput = false;
		return;
	}
	const unsigned char *p = (const unsigned char *)text;
	while (*p)
	{
		unsigned int c = 0;
		if ((*p & 0x80u) == 0)
		{
			c = *p++;
		}
		else if ((*p & 0xE0u) == 0xC0u)
		{
			if (!p[1])
				break;
			c = (unsigned int)((p[0] & 0x1Fu) << 6) | (p[1] & 0x3Fu);
			p += 2;
		}
		else if ((*p & 0xF0u) == 0xE0u)
		{
			if (!p[1] || !p[2])
				break;
			c = (unsigned int)((p[0] & 0x0Fu) << 12) | ((p[1] & 0x3Fu) << 6) | (p[2] & 0x3Fu);
			p += 3;
		}
		else
		{
			++p;
			continue;
		}
		// Enter is handled via SDL_KEYDOWN so we do not double-fire with TEXTINPUT
		if (c == '\r' || c == '\n')
			continue;
		mainLoopObject->textWrite(c);
	}
}
#endif

//
// La plus importante. Cr� la fen�tre et init les cossin
//
int dkwInit(int width, int height, int mcolorDepth, char* mTitle, CMainLoopInterface *mMainLoopObject, bool fullScreen, int refreshRate)
{
    mainLoopObject = mMainLoopObject;

    // Setup SDL
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) != 0)
    {
        last_error = std::string("Error: ") + SDL_GetError() + "\n";
        return 0;
    }

    // Decide GL+GLSL versions
#if __APPLE__
    // GL 3.2 Core + GLSL 150
    const char* glsl_version = "#version 150";
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG); // Always required on Mac
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
#elif defined(_WIN32)
    // GL 3.0 Compatibility + GLSL 130 — Core Profile on Windows returns NULL for legacy
    // GL1.x symbols via wglGetProcAddress, which crashes BrebisGL when those functions
    // (glBegin, glMaterialfv, etc.) are called by the game.
    const char* glsl_version = "#version 130";
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_COMPATIBILITY);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
#else
    // GL 3.0 + GLSL 130
    const char* glsl_version = "#version 130";
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, 0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 0);
#endif

    // Create window with graphics context
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
    SDL_GL_SetAttribute(SDL_GL_STENCIL_SIZE, 8);
    SDL_DisplayMode current;
    SDL_GetCurrentDisplayMode(0, &current);
    bool autoDetect = (width == 0 || height == 0);
    if (autoDetect)
    {
        width = current.w;
        height = current.h;
    }
    Uint32 flags = SDL_WINDOW_OPENGL | SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI;
    if (fullScreen)
    {
        // FULLSCREEN_DESKTOP avoids a display-mode change and scales nothing;
        // use it when auto-detecting so the window exactly matches the desktop.
        flags |= autoDetect ? SDL_WINDOW_FULLSCREEN_DESKTOP : SDL_WINDOW_FULLSCREEN;
    }
    window = SDL_CreateWindow(mTitle, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, width, height, flags);
    gl_context = SDL_GL_CreateContext(window);
    SDL_GL_SetSwapInterval(1); // Enable vsync

    if (brebisGLInit() == KHRONOS_FALSE)
    {
        last_error = "Failed to initialize BrebisGL\n";
        return 0;
    }

    done = false;

    return 1;
}

//
// Pour forcer l'application � fermer
//
void dkwForceQuit()
{
#ifdef DEDICATED_SERVER
	extern bool quit;
	quit = true;
#else
	done = true;
#endif
}

//
// On obtien le Device Context de la fenetre
//
SDL_GLContext dkwGetDC()
{
    return gl_context;
}

//
// On obtien le handle de la fen�tre
//
SDL_Window* dkwGetHandle()
{
    return window;
}

//
// Obtenir la derni�re erreur
//
char* dkwGetLastError()
{
    return (char*)last_error.c_str();
}

//
// Pour retourner la position de la sourie sur l'�cran
//
CVector2i dkwGetCursorPos()
{
    return dkiGetMouse();
}

//
// On retourne la r�solution de la fen�tre
//
CVector2i dkwGetResolution()
{
    SDL_Window* pWindow = SDL_GL_GetCurrentWindow();
    int w, h;
    SDL_GL_GetDrawableSize(pWindow, &w, &h);

    return { w, h };
}

// On clip la mouse au window rect
void dkwClipMouse( bool abEnabled )
{
}

//
// On effectu le loop principal de l'application
//
int dkwMainLoop()
{
    // Poll and handle events (inputs, window resize, etc.)
    // You can read the io.WantCaptureMouse, io.WantCaptureKeyboard flags to tell if dear imgui wants to use your inputs.
    // - When io.WantCaptureMouse is true, do not dispatch mouse input data to your main application.
    // - When io.WantCaptureKeyboard is true, do not dispatch keyboard input data to your main application.
    // Generally you may always pass all inputs to dear imgui, and hide them from your application based on those two flags.
    SDL_Event event;

    int(*sdlEventCall)(SDL_Event * event) = SDL_WaitEvent;

    while (SDL_PollEvent(&event))
    {
        //ImGui_ImplSDL2_ProcessEvent(&event);
        if (event.type == SDL_QUIT)
            done = true;
        if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window))
            done = true;
#ifndef DEDICATED_SERVER
		if (mainLoopObject && window)
		{
			const Uint32 ourId = SDL_GetWindowID(window);
			if (event.type == SDL_TEXTINPUT)
			{
				if (event.text.windowID == ourId || event.text.windowID == 0)
					dkwSendTextUtf8(event.text.text);
			}
			else if (event.type == SDL_KEYUP)
			{
				const SDL_Keycode sym = event.key.keysym.sym;
				if (sym == SDLK_LALT || sym == SDLK_RALT)
				{
					s_skipNextSingleDigitTextinput = false;
					if (writting && s_altcodeValue >= 0)
					{
						unsigned int c = (unsigned int)s_altcodeValue;
						if (c > 0x10FFFFu)
							c &= 0xFFFFu;
						mainLoopObject->textWrite(c);
					}
					s_altcodeValue = -2;
				}
			}
			else if (event.type == SDL_KEYDOWN)
			{
				if (event.key.windowID != 0 && event.key.windowID != ourId)
					;
				else
				{
					const SDL_Keycode sym = event.key.keysym.sym;
					// Do not treat Alt autorepeat as a new chord (would clear digits mid-sequence).
					if ((sym == SDLK_LALT || sym == SDLK_RALT) && event.key.repeat == 0)
						s_altcodeValue = -1;

					bool ate_alt_digit = false;
					if (writting && dkw_mod_alt_for_codes())
					{
						const int d = dkw_keycode_to_digit(sym);
						if (d >= 0)
						{
							if (s_altcodeValue < 0)
								s_altcodeValue = d;
							else if (s_altcodeValue <= 111411)
								s_altcodeValue = s_altcodeValue * 10 + d;
							s_skipNextSingleDigitTextinput = true;
							ate_alt_digit = true;
						}
					}
					if (!ate_alt_digit)
					{
						if (sym == SDLK_BACKSPACE)
							mainLoopObject->textWrite(8);
						else if (sym == SDLK_RETURN || sym == SDLK_KP_ENTER)
							mainLoopObject->textWrite(13);
					}
				}
			}
		}
#endif
        //if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_SIZE_CHANGED)
        //{
        //    width = event.window.data1;
        //    height = event.window.data2;
        //}
    }

    mainLoopObject->paint();

	return done ? 0 : 1;
}

//
// Pour shutdowner le tout
//
void dkwShutDown()
{
}

//
// Pour forcer un update des messages (meton pendant un loading)
//
void dkwUpdate()
{
}
