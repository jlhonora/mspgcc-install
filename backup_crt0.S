/*  -*- Mode: Asm -*-  */
#if WITH_DISABLE_WDT
#define WDTIMER_KICK
#else /* WITH_DISABLE_WDT */
#define WDTIMER_KICK \
	mov	&__wdt_clear_value, &__WDTCTL
#endif /* WITH_DISABLE_WDT */
/******* CRT support functions *********/

/* The following sections are arranged in exactly this order by the loader,
 * right before the text region.
	;; .init0 (_reset_vector__: Start here after reset)
	;; .init1 (User definable)
	;; .init2 (__init_stack: Initialize stack)
	;; .init3 (__low_level_init: Initialize hardware; user definable)
	;; .init4 (__do_copy_data; __do_clear_bss: Copy data to .data, clear bss)
	;; .init5 (User definable)
	;; .init6 (__do_global_ctors: C++ constructors)
	;; .init7 (User definable)
	;; .init8 (User definable)
	;; .init9 (main)
	;; .fini9 (__stop_progExec__: Falls into here after main(). User definable)
	;; .fini8 (User definable)
	;; .fini7 (User definable)
	;; .fini6 (C++ destructors)
	;; .fini5 (User definable)
	;; .fini4 (User definable)
	;; .fini3 (User definable)
	;; .fini2 (User definable)
	;; .fini1 (User definable)
	;; .fini0 (_endless_loop__: Infinite loop after program termination)

NOTE: If you override any of the startup functions, ensure you put the
	replacement in the correct section.
*/

#if defined(L_reset_vector__)
/*****************************************************************
 * Program starts here.
 *   overwriting this label in the user program
 *   causes removing all startup code except __do_global_ctors
 *****************************************************************/
	.section .init0, "ax", @progbits

	.global	_reset_vector__
	.weak   _reset_vector__

	.func   _reset_vector__

	;; .init0 (Start here after reset)
_reset_vector__:

	;; .init1 (Initialize watchdog support)
	.global __watchdog_support
	;; .init2 (Initialize stack)
	.global	__init_stack
	;; .init3 (Initialize hardware: user definable)
	.global	__low_level_init
	;; .init4 (Copy data to .data, clear bss)
	.global __do_copy_data
	.global __do_clear_bss
	;; .init5 (User definable)
	;; .init6 (C++ constructors)
	/* .global __do_global_ctors ; Do not reference unless ctors exist */
	;; .init7 (User definable)
	;; .init8 (User definable)
	;; .init9 (Main routine)
	
	;; compiler places the main routine in .init9 unless it is "hosted"
	
	;; .fini9 (__stop_progExec__: Falls into here after .init9. User definable)
	.global __stop_progExec__
	;; .fini8 (User definable)
	;; .fini7 (User definable)
	;; .fini6 (C++ destructors)
	/* .global __do_global_dtors ; Do not reference unless dtors exist */
	;; .fini5 (User definable)
	;; .fini4 (User definable)
	;; .fini3 (User definable)
	;; .fini2 (User definable)
	;; .fini1 (User definable)
	;; .fini0 (_endless_loop__: Infinite loop after program termination)
	.global _endless_loop__

	.endfunc
#endif  /* defined(L_reset_vector__) */
	
#if defined(L__watchdog_support)
/*****************************************************************
 * Initialize watchdog support
 * Depending on variant selected, watchdog is disabled or its restart
 * value is loaded into __wdt_clear_value for use throughout execution
 *****************************************************************/
	.section .init1, "ax", @progbits

	.global	__watchdog_support
	.weak   __watchdog_support

	.func   __watchdog_support

__watchdog_support:
#if WITH_DISABLE_WDT
	mov     #0x5a80, &__WDTCTL
#else /* WITH_DISABLE_WDT */
	mov.b	&__WDTCTL, r5
	bis	#0x5a08, r5
	mov	r5, &__wdt_clear_value
#endif /* WITH_DISABLE_WDT */
	.endfunc
	
#if ! WITH_DISABLE_WDT
        .section        .noinit.crt0,"aw",@nobits
        .p2align 1,0
        .type   __wdt_clear_value,@object
        .size   __wdt_clear_value,2
	.global	__wdt_clear_value
__wdt_clear_value:
        .skip 2,0
#endif /* WITH_DISABLE_WDT */

#endif

#if defined(L__init_stack)
/*****************************************************************
 * Set stack pointer
 * can be overwriten
    stack can be initialized in main() prologue,
    but setting stack pointer here allows to call subroutines 
    from startup code and call constructors of statically allocated C++ objects.
    Stack pointer will have the same value entering main() as here,
    so -mno-stack-init can be used to reduce code size.
    initial stack value can be set in ld script as __stack symbol 
    (end of RAM by default), or via -defsym __stack=<address> ld option
    or via -Wl,defsym,__stack=<address> gcc option, or by redefining
    __init_stack function as follows:

#if defined (__cplusplus)
extern "C" 
endif
__attribute__((__naked__)) __attribute__((section(".init2"))) void __init_stack()
{
    asm volatile("\tmov\t#stack_addr, r1\n");
}

 *****************************************************************/
	.section .init2, "ax", @progbits

	.global	__init_stack
	.weak   __init_stack

	.func   __init_stack

__init_stack:
	mov     #__stack, r1

	.endfunc
#endif

#if defined(L__low_level_init)
/*****************************************************************
 * Initialize peripherals
 * Available for user override
 *****************************************************************/
	.section .init3, "ax", @progbits

	.global	__low_level_init
	.weak   __low_level_init

	.func   __low_level_init

__low_level_init:
	.endfunc
#endif

#if defined(L_copy_data)
/*****************************************************************
 * Initialize data: copy data 
 * from __data_load_start ( = _etext) to __data_start
 * can be overwriten
 *****************************************************************/
	.section .init4, "ax", @progbits

	.global __do_copy_data
	.weak   __do_copy_data

	.func   __do_copy_data

__do_copy_data:
	mov     #__data_size, r15
	tst     r15
	jz      .L__copy_data_end
.L__copy_data_loop:
	WDTIMER_KICK
	decd    r15
	mov.w   __data_load_start(r15), __data_start(r15)    ; data section is word-aligned, so word transfer is acceptable
	jne     .L__copy_data_loop
.L__copy_data_end:

	.endfunc
#endif /* defined(L_copy_data) */
    
#if defined(L_clear_bss)
/*****************************************************************
 * Initialize data: clear .bss
 * can be overwriten
 *****************************************************************/
	.section .init4, "ax", @progbits

	.global __do_clear_bss
	.weak   __do_clear_bss

	.func   __do_clear_bss

__do_clear_bss:
	mov     #__bss_size, r15
	tst     r15
	jz      .L__clear_bss_end
.L__clear_bss_loop:
	WDTIMER_KICK
	dec     r15
	clr.b   __bss_start(r15)
	jne     .L__clear_bss_loop
.L__clear_bss_end:

	.endfunc
#endif  /* defined(L_clear_bss) */

#if defined(L__stop_progExec__)
/*****************************************************************
 * Execute after main returns
 * Default implementation does nothing
 *****************************************************************/
	.section .fini9, "ax", @progbits
	.global __stop_progExec__
	.weak	__stop_progExec__

	.func  __stop_progExec__
__stop_progExec__:
	.endfunc
	
#endif

#if defined(L_endless_loop__)
/*****************************************************************
 * Placed at end of CRT code unless overridden
 * Default implementation loops entering LPM4, leaving GIE unchanged
 *****************************************************************/
	.section .fini0, "ax", @progbits

	.global _endless_loop__
	.weak	_endless_loop__
	.func   _endless_loop__

_endless_loop__:
	bis	#0xf0, r2
	jmp  _endless_loop__

	.endfunc

#endif  /* defined(L_endless_loop__) */
    
#if defined(L_ctors430)
/*****************************************************************
 * Call constructor functions.
 *
 * No reference to this should be generated unless a function pointer
 * is added to the .ctors section.  This means that the code will
 * be absent from the executable unless at least one pointer is
 * present, which also means we don't have to check for an empty
 * function list.
 *****************************************************************/
	.section .init6, "ax", @progbits
	.global __do_global_ctors
	.weak   __do_global_ctors
    
	.func   __do_global_ctors

__do_global_ctors:
	mov     #__ctors_start, r11
	mov     #__ctors_end,   r10
.L__ctors_loop:
	WDTIMER_KICK
	call	@r11+	; call constructor
	cmp     r10, r11
	jne     .L__ctors_loop

	.endfunc
#endif
    
#if defined(L_dtors430)
/*****************************************************************
 * Call destructor functions.
 *
 * No reference to this should be generated unless a function pointer
 * is added to the .dtors section.  This means that the code will
 * be absent from the executable unless at least one pointer is
 * present, which also means we don't have to check for an empty
 * function list.
 *****************************************************************/
	.section .fini6,"ax",@progbits
	.global __do_global_dtors
	.weak   __do_global_dtors
    
	.func   __do_global_dtors

__do_global_dtors:
	mov     #__dtors_start, r11
	mov     #__dtors_end, r10
.L__dtors_loop:
	WDTIMER_KICK
	call    @r11+
	cmp     r10, r11
	jne     .L__dtors_loop

	.endfunc
#endif

#if defined(L_unexpected_)

/*****************************************************************
 * unexpected interrupt vector handler
 * can be overwriten by user function with the same name:
 *   void _unexpected_ __attribute__((interrupt)) { }
 *
 *****************************************************************/

	.section .text.crt0, "ax", @progbits

	.global	_unexpected_
        .weak   _unexpected_

        .p2align 1,0
_unexpected_:
        reti
	
#endif
