#include "type.h"
#include "const.h" // Interrupt Vector in const.h
#include "proto.h"
#include "protect.h"

PUBLIC void init_8259A()
{

    out_byte(INT_M_CTL, 0x11); // Master ICW1
    out_byte(INT_S_CTL, 0x11); // Slave ICW1
    out_byte(INT_M_CTLMASK,	INT_VECTOR_IRQ0); // Master ICW2
	out_byte(INT_S_CTLMASK,	INT_VECTOR_IRQ8); // Slave ICW2
	out_byte(INT_M_CTLMASK,	0x4); // Master ICW3
	out_byte(INT_S_CTLMASK,	0x2); // Slave ICW3 
	out_byte(INT_M_CTLMASK,	0x1); // Master ICW4
	out_byte(INT_S_CTLMASK,	0x1); // Slave ICW4
	out_byte(INT_M_CTLMASK,	0xFD); // Master OCW1
	out_byte(INT_S_CTLMASK,	0xFF); // Slave OCW1
}

/* referenced by core.asm(hwint__) */
PUBLIC void spurious_irq(int irq)
{
    put_string("spurious_irq: ");
    put_string((char*)irq);
    put_string("\n");
}
