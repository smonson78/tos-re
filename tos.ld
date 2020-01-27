SECTIONS {
    .ram : {
        *(.ram)
    }

    .cart : {
        *(.cart)
    }

	.text . : SUBALIGN(0) {
		*(.text)
	}

	.data : {
		. = ALIGN(2);
		*(.data*)
		*(.rodata*)
	}

	.bss : {
		*(.bss)
		. = ALIGN(2);
	}

    .mmu : {
        *(.mmu)
    }

	/DISCARD/ : {
		*(.group)
		*(.comment)
		*(.debug*)
	}
}
