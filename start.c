#include "type.h"
#include "const.h"
#include "protect.h"
#include "proto.h"
#include "global.h"

PUBLIC void cstart()
{
    u16* p_idt_limit = (u16*)(&idt_ptr[0]);
    u32* p_idt_base = (u32*)(&idt_ptr[2]);
	*p_idt_limit = IDT_SIZE * sizeof(GATE) - 1;
	*p_idt_base = (u32)&idt;

	init_prot();
    put_string("Welcome to MarmaladeOS");
}

