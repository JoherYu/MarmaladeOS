#include "type.h"
#include "const.h" //privilege
#include "protect.h"
#include "global.h"
#include "proto.h"

PRIVATE void init_idt_desc(unsigned char vector, u8 desc_type, 
    int_handler handler, unsigned char privilege);
/* interrupt handlers which are defined in core.asm*/
void divide_error();
void single_step_exception();
void nmi();
void breakpoint_exception();
void overflow();
void bounds_check();
void inval_opcode();
void copr_not_available();
void double_fault();
void copr_seg_overrun();
void inval_tss();
void segment_not_present();
void stack_exception();
void general_protection();
void page_fault();
void copr_error();
void hwint00();
void hwint01();
void hwint02();
void hwint03();
void hwint04();
void hwint05();
void hwint06();
void hwint07();
void hwint08();
void hwint09();
void hwint10();
void hwint11();
void hwint12();
void hwint13();
void hwint14();
void hwint15();

PUBLIC void init_prot()
{
    init_8259A();

    /* all initialized as interrupt gate */
    init_idt_desc(INT_VECTOR_DIVIDE, DA_386IGATE, 
        divide_error, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_DEBUG,	DA_386IGATE,
		single_step_exception, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_NMI, DA_386IGATE,
		nmi, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_BREAKPOINT, DA_386IGATE,
		breakpoint_exception, PRIVILEGE_USER);
	init_idt_desc(INT_VECTOR_OVERFLOW, DA_386IGATE,
		overflow, PRIVILEGE_USER);
	init_idt_desc(INT_VECTOR_BOUNDS, DA_386IGATE,
	    bounds_check, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_INVAL_OP, DA_386IGATE,
	    inval_opcode, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_COPROC_NOT, DA_386IGATE,
	    copr_not_available,	PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_DOUBLE_FAULT, DA_386IGATE,
	    double_fault, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_COPROC_SEG, DA_386IGATE,
	    copr_seg_overrun, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_INVAL_TSS,	DA_386IGATE,
	    inval_tss, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_SEG_NOT, DA_386IGATE,
	    segment_not_present, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_STACK_FAULT, DA_386IGATE,
	    stack_exception, PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_PROTECTION, DA_386IGATE,
	    general_protection,	PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_PAGE_FAULT, DA_386IGATE,
	    page_fault,	PRIVILEGE_KRNL);
	init_idt_desc(INT_VECTOR_COPROC_ERR, DA_386IGATE,
	    copr_error,	PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 0, DA_386IGATE,
        hwint00, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 1, DA_386IGATE,
        hwint01, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 2, DA_386IGATE,
        hwint02, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 3, DA_386IGATE,
        hwint03, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 4, DA_386IGATE,
        hwint04, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 5, DA_386IGATE,
        hwint05, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 6, DA_386IGATE,
        hwint06, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ0 + 7, DA_386IGATE,
        hwint07, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 0, DA_386IGATE,
        hwint08, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 1, DA_386IGATE,
        hwint09, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 2, DA_386IGATE,
        hwint10, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 3, DA_386IGATE,
        hwint11, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 4, DA_386IGATE,
        hwint12, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 5, DA_386IGATE,
        hwint13, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 6, DA_386IGATE,
        hwint14, PRIVILEGE_KRNL);
    init_idt_desc(INT_VECTOR_IRQ8 + 7, DA_386IGATE,
        hwint15, PRIVILEGE_KRNL);
}

PRIVATE void init_idt_desc(unsigned char vector, u8 desc_type, 
    int_handler handler, unsigned char privilege)
{
    GATE* p_gate = &idt[vector];
    u32 base = (u32)handler; //TODO
    p_gate->offset_low = base & 0xFFFF;
    p_gate->selector	= SELECTOR_KERNEL_CS;
	p_gate->dcount		= 0;
	p_gate->attr		= desc_type | (privilege << 5);
	p_gate->offset_high	= (base >> 16) & 0xFFFF;
}

/* referenced by core.asm */
PUBLIC void exception_handler(int vec_no, int err_code, int eip, int cs, int eflags)
{
    char* err_msg[] = {
        "#DE Divide Error",
        "#DB RESERVED",
	    "—  NMI Interrupt",
		"#BP Breakpoint",
		"#OF Overflow",
		"#BR BOUND Range Exceeded",
		"#UD Invalid Opcode (Undefined Opcode)",
		"#NM Device Not Available (No Math Coprocessor)",
		"#DF Double Fault",
		"    Coprocessor Segment Overrun (reserved)",
		"#TS Invalid TSS",
	    "#NP Segment Not Present",
	    "#SS Stack-Segment Fault",
	    "#GP General Protection",
	    "#PF Page Fault",
	    "—  (Intel reserved. Do not use.)",
	    "#MF x87 FPU Floating-Point Error (Math Fault)",
	    "#AC Alignment Check",
	    "#MC Machine Check",
	    "#XF SIMD Floating-Point Exception"
    };

    put_string("Exception! -> ");
    put_string((char*)err_msg[vec_no]);
    put_string("\n\n");
    put_string("EFLAGS:");
    put_string((char*)eflags);
    put_string("CS:");
    put_string((char*)cs);
    put_string("EIP:");
    put_string((char*)eip);

    if (err_code != 0xFFFFFFFF)
    {
        put_string("Error code:");
        put_string((char*)err_code);
    }
    
}
