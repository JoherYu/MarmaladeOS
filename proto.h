PUBLIC void* memcpy(void* p_dst, void* p_src, int size);
PUBLIC void	out_byte(u16 port, u8 value);
PUBLIC u8 in_byte(u16 port);
PUBLIC void	put_string(char * info);
PUBLIC void	init_prot();
PUBLIC void	init_8259A();