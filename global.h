/* "GLOBAL_VARIABLES_HERE" is defined in global.c
   "EXTERN" is defined in const.h
   so after pre-compile,the "EXTERN" would be replaced with "extern" except in global.c,
   there's no extern before variables in global.c
 */
#ifdef GLOBAL_VARIABLES_HERE
#undef EXTERN
#define EXTERN
#endif

EXTERN u8 idt_ptr[6]; // alias is defined in type.h
EXTERN GATE idt[IDT_SIZE]; // "GATE" is defined in protect.h