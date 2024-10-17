#pragma once
int ffmpeg(int argc, const char **argv);
int ffplay(int argc, const char **argv);
typedef int (*FuncFormatContextPtr)(AVFormatContext *);
typedef int (*FuncPlayTimePtr)(double time);
typedef int (*FuncStartLoadingPtr)(void);
typedef int (*FuncHiddenLoadingPtr)(void);
int ffplay_with_parent(int argc, const char **argv, void* parent, int(*sdl_call_back)(void *data), FuncFormatContextPtr format_call_back);
int ffplay_event_loop(void);
int ffplay_pause(void);
int ffplay_resume(void);
int ffplay_next_frame(void);
int ffplay_seek_by_add(double seek_s);
int ffplay_seek_time_s(double seek_s);
int ffplay_mute_enable(int mute);
int ffplay_close(void);

int ffplay_set_play_time_callback(FuncPlayTimePtr callback);
int ffplay_set_start_loading_callback(FuncStartLoadingPtr callback);
int ffplay_set_hidden_loading_callback(FuncStartLoadingPtr callback);
