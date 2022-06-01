CFLAGS=-m32 -g -fno-stack-protector -static -Wall -fno-pie -fno-pic
LIB=-L../../../__libsym__/ -lsym
LIBBEARSSL= -I./inc -L./. -lbearssl
WRAPPER=${NAME}_wrapper


.PHONY: aes_ct des_ct
all: aes_ct des_ct

define compile_aes_ct
	gcc $(CFLAGS) $(1)_wrapper.c -o $(1)_$(2)  $(LIB) $(LIBBEARSSL) -D DATA_LEN=$(2)
endef

aes_ct:
	@$(call compile_aes_ct,aes_ct,16)
	@$(call compile_aes_ct,aes_ct,32)
	@$(call compile_aes_ct,aes_ct,48)
	@$(call compile_aes_ct,aes_ct,64)
	@$(call compile_aes_ct,aes_ct,80)
	@$(call compile_aes_ct,aes_ct,96)

define compile_des_ct
	gcc $(CFLAGS) $(1)_wrapper.c -o $(1)_$(2)  $(LIB) $(LIBBEARSSL) -D DATA_LEN=$(2)
endef

des_ct:
	@$(call compile_des_ct,des_ct,8)
	@$(call compile_des_ct,des_ct,16)
	@$(call compile_des_ct,des_ct,24)
	@$(call compile_des_ct,des_ct,32)
	@$(call compile_des_ct,des_ct,40)
	@$(call compile_des_ct,des_ct,48)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2

mrproper: clean
	find . -type f -executable | xargs rm
