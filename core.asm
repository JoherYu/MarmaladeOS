extern cstart
extern exception_handler
extern spurious_irq

extern idt_ptr

global _start ;export _start for the linker

global	divide_error
global	single_step_exception
global	nmi
global	breakpoint_exception
global	overflow
global	bounds_check
global	inval_opcode
global	copr_not_available
global	double_fault
global	copr_seg_overrun
global	inval_tss
global	segment_not_present
global	stack_exception
global	general_protection
global	page_fault
global	copr_error
global  hwint00
global  hwint01
global  hwint02
global  hwint03
global  hwint04
global  hwint05
global  hwint06
global  hwint07
global  hwint08
global  hwint09
global  hwint10
global  hwint11
global  hwint12
global  hwint13
global  hwint14
global  hwint15

;-------------------------------------------------------------------------------
%macro hwint_master 1
        push %1
        call spurious_irq
        add esp,4
%endmacro

;-------------------------------------------------------------------------------
%macro  hwint_slave     1
        push    %1
        call    spurious_irq
        add     esp, 4
        hlt
%endmacro

;===============================================================================
SECTION CORE ;elf file can't use vstart
_start:
        [bits 32]
        call cstart
        lidt [idt_ptr]
        sti
        hlt

hwint00: ;Interrupt routine for irq 0 (the clock)
        hwint_master 0
hwint01: ;Interrupt routine for irq 1 (keyboard)
        hwint_master 1
hwint02: ;Interrupt routine for irq 2 (cascade!)
        hwint_master 2
hwint03: ;Interrupt routine for irq 3 (second serial)
        hwint_master 3
hwint04: ;Interrupt routine for irq 4 (first serial)
        hwint_master 4
hwint05: ;Interrupt routine for irq 5 (XT winchester)
        hwint_master 5
hwint06: ;Interrupt routine for irq 6 (floppy)
        hwint_master 6
hwint07: ;Interrupt routine for irq 7 (printer)
        hwint_master 7
hwint08: ;Interrupt routine for irq 8 (realtime clock).
        hwint_slave 8
hwint09: ;Interrupt routine for irq 9 (irq 2 redirected)
        hwint_slave 9
hwint10: ;Interrupt routine for irq 10
        hwint_slave 10
hwint11: ;Interrupt routine for irq 11
        hwint_slave 11
hwint12: ;Interrupt routine for irq 12
        hwint_slave 12
hwint13: ;Interrupt routine for irq 13 (FPU exception)
        hwint_slave 13
hwint14: ;Interrupt routine for irq 14 (AT winchester)
        hwint_slave 14
hwint15: ;Interrupt routine for irq 15
        hwint_slave 15

divide_error:
        push 0xFFFFFFFF ;no err code
        push 0 ;vector_no = 0
        jmp exception
single_step_exception:
	    push 0xFFFFFFFF	;no err code
	    push 1 ;vector_no = 1
	    jmp	exception
nmi:
	    push 0xFFFFFFFF	;no err code
	    push 2 ;vector_no = 2
	    jmp	exception
breakpoint_exception:
	    push 0xFFFFFFFF	;no err code
	    push 3 ;vector_no = 3
	    jmp	exception
overflow:
	    push 0xFFFFFFFF	;no err code
	    push 4 ;vector_no = 4
	    jmp	exception
bounds_check:
	    push 0xFFFFFFFF	;no err code
	    push 5 ;vector_no = 5
	    jmp	exception
inval_opcode:
	    push 0xFFFFFFFF	;no err code
	    push 6 ;vector_no = 6
	    jmp	exception
copr_not_available:
	    push 0xFFFFFFFF	;no err code
	    push 7 ;vector_no = 7
	    jmp	exception
double_fault:
	    push 8 ;vector_no = 8
	    jmp	exception
copr_seg_overrun:
	    push 0xFFFFFFFF	;no err code
	    push 9 ;vector_no = 9
	    jmp	exception
inval_tss:
	    push 10	;vector_no = A
	    jmp	exception
segment_not_present:
	    push 11	;vector_no = B
	    jmp	exception
stack_exception:
	    push 12 ;vector_no = C
	    jmp	exception
general_protection:
	    push 13	;vector_no = D
	    jmp	exception
page_fault:
	    push 14	;vector_no = E
	    jmp	exception
copr_error:
	    push 0xFFFFFFFF	;no err code
	    push 16	;vector_no = 10h
	    jmp	exception

exception:
        call exception_handler
        add esp,4*2 ;Let the top of the stack point to EIP, 
                    ;and the stack from the top down is: EIP, CS, EFLAGS
        hlt
