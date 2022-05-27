CFLAGS=-Wall -m32 -g -fno-stack-protector -static -Wno-parentheses
LIB=-L../../__libsym__/ -lsym
ENCR=tea_encrypt
DECR=tea_encrypt
.PHONY: all clean

.PHONY: all tea_decrypt_O0 tea_decrypt_O1 tea_decrypt_O2 tea_decrypt_O3 tea_decrypt_Of tea_encrypt_O0 tea_encrypt_O1 tea_encrypt_O2 tea_encrypt_O3 tea_encrypt_Of

all: tea_decrypt_O0 tea_decrypt_O1 tea_decrypt_O2 tea_decrypt_O3 tea_decrypt_Of tea_encrypt_O0 tea_encrypt_O1 tea_encrypt_O2 tea_encrypt_O3 tea_encrypt_Of

define compile
	echo "-------------------"
	echo " Compiling $(1)"
	echo "-------------------"
	gcc-5 -fno-stack-protector $(CFLAGS) -O0 tea.c $(1)_wrapper.c -o $(1)_gcc5_O0 $(LIB)
	gcc-5 -fno-stack-protector $(CFLAGS) -O3 tea.c $(1)_wrapper.c -o $(1)_gcc5_O3 $(LIB)
	gcc-8 -fno-stack-protector $(CFLAGS) -O0 tea.c $(1)_wrapper.c -o $(1)_gcc8_O0 $(LIB)
	gcc-8 -fno-stack-protector $(CFLAGS) -O3 tea.c $(1)_wrapper.c -o $(1)_gcc8_O3 $(LIB)
	clang-3.9 $(CFLAGS) -O0 tea.c $(1)_wrapper.c -o $(1)_cl39_O0 $(LIB)
	clang-3.9 $(CFLAGS) -O3 tea.c $(1)_wrapper.c -o $(1)_cl39_O3 $(LIB)
	clang-3.0 $(CFLAGS) -O0 tea.c $(1)_wrapper.c -o $(1)_cl30_O0 $(LIB)
	clang-3.0 $(CFLAGS) -O3 tea.c $(1)_wrapper.c -o $(1)_cl30_O3 $(LIB)
	clang-7 $(CFLAGS) -O0 tea.c $(1)_wrapper.c -o $(1)_cl7_O0 $(LIB)
	clang-7 $(CFLAGS) -O3 tea.c $(1)_wrapper.c -o $(1)_cl7_O3 $(LIB)
endef

define test
	@echo -n "$(1): "
	@mkdir -p $(LOG)
	@mkdir -p /tmp/SMTDIR/trace/; rm -R /tmp/SMTDIR/; mkdir -p /tmp/SMTDIR/trace/
	$(eval PARAMS := -relse -relse-leak-info halt -relse-dedup 1 -relse-fp instr \
	-fml-solver-timeout 0 -relse-timeout 3600 -sse-depth 10000 \
	-relse-paths 50 -sse-memory memory.txt -sse-load-ro-sections \
	-sse-load-sections .got.plt,.data,.plt -fml-solver boolector \
	-relse-store-type sha -relse-memory-type row-map 	\
	-sse-address-trace-file /tmp/SMTDIR/trace/ -sse-smt-dir \
	/tmp/SMTDIR/ -sse-comment  -relse-print-model \
	$(1))
	@echo "binsec $(PARAMS)" > $(LOG)/$(1)
	binsec $(PARAMS) >> $(LOG)/$(1) 2>&1 && \
	([ $$? -eq 0 ] && echo "PASS") || echo "FAIL!"
endef

define full_test
	@echo "-------------------"
	@echo " Testing $(1)"
	@echo "-------------------"
	$(call test,$(1)_"gcc5_O0")
	$(call test,$(1)_"gcc5_O3")
	$(call test,$(1)_"gcc8_O0")
	$(call test,$(1)_"gcc8_O3")
	$(call test,$(1)_"cl30_O0")
	$(call test,$(1)_"cl30_O3")
	$(call test,$(1)_"cl39_O0")
	$(call test,$(1)_"cl39_O3")
	$(call test,$(1)_"cl7_O0")
	$(call test,$(1)_"cl7_O3")
endef

# TEA Decrypt
WRAPPER=${DECR}_wrapper

tea_decrypt_O0:
	gcc $(CFLAGS) ${WRAPPER}.c -O0 -o $@  $(LIB)

tea_decrypt_O1:
	gcc $(CFLAGS) ${WRAPPER}.c -O1 -o $@  $(LIB)

tea_decrypt_O2:
	gcc $(CFLAGS) ${WRAPPER}.c -O2 -o $@  $(LIB)

tea_decrypt_O3:
	gcc $(CFLAGS) ${WRAPPER}.c -O3 -o $@  $(LIB)

tea_decrypt_Of:
	gcc $(CFLAGS) ${WRAPPER}.c -Ofast -o $@  $(LIB)

tea_encrypt_O0:
	gcc $(CFLAGS) ${WRAPPER}.c -O0 -o $@  $(LIB)

# TEA Encrypt
WRAPPER=${ENCR}_wrapper

tea_encrypt_O1:
	gcc $(CFLAGS) ${WRAPPER}.c -O1 -o $@  $(LIB)

tea_encrypt_O2:
	gcc $(CFLAGS) ${WRAPPER}.c -O2 -o $@  $(LIB)

tea_encrypt_O3:
	gcc $(CFLAGS) ${WRAPPER}.c -O3 -o $@  $(LIB)

tea_encrypt_Of:
	gcc $(CFLAGS) ${WRAPPER}.c -Ofast -o $@  $(LIB)

tea_decrypt:
	@$(call compile,$@)
	@$(call full_test,$@)

tea_encrypt:
	@$(call compile,$@)
	@$(call full_test,$@)

analysis:
	@$(call full_test,tea_encrypt)
	@$(call full_test,tea_decrypt)

clean:
	rm -rf *.o *.csv *.out smtdir/*/*.smt2

mrproper: clean
	find . -type f -executable | xargs rm
