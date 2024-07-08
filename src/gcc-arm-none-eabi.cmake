# STM32F446RE High-performance foundation line, Arm Cortex-M4 core with DSP and FPU, 512 Kbytes of Flash memory, 180 MHz CPU, ART Accelerator, Dual QSPI
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(TOOLCHAIN_PREFIX                arm-none-eabi-)

set(CMAKE_C_COMPILER                ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_ASM_COMPILER              ${CMAKE_C_COMPILER})
set(CMAKE_CXX_COMPILER              ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_LINKER                    ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_OBJCOPY                   ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_SIZE                      ${TOOLCHAIN_PREFIX}size)
set(CMAKE_RANLIB                    ${TOOLCHAIN_PREFIX}ranlib)
set(CMAKE_STRIP                     ${TOOLCHAIN_PREFIX}strip)

set(CMAKE_EXECUTABLE_SUFFIX         ".elf")
# https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html
# https://gcc.gnu.org/onlinedocs/gcc/ARM-Options.html arm options
set(TARGET_FLAGS
    # Cortex-M4 core
    -mcpu=cortex-m4 
    # Arm extension: Floating point units. Single precision. 16 64-bit FPU registers
    -mfpu=fpv4-sp-d16 
    # Uses floating point instructions and the floating-point ABI (Application Binary Interface), use floating point hardware with FPU registers. 
    # As opposed to soft versions which support software, use general purpose registers
    -mfloat-abi=hard 
    # informs the compiler to generate code using the 16-bit Arm Thumb instruction set (suitable for risc)
    # The CISC (old) approach attempts to minimize the number of instructions per program, sacrificing the number of 
    # cycles per instruction. RISC does the opposite, reducing the cycles per instruction at the cost of the number of instructions per program.
    -mthumb
)
add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX,ASM>:${TARGET_FLAGS}>")

# https://gcc.gnu.org/onlinedocs/gcc-4.4.2/gcc/Preprocessor-Options.html
# https://gcc.gnu.org/onlinedocs/gcc/Spec-Files.html
set(ASM_ONLY_TARGET_FLAGS
    -c #Pass comments through to the output file
    -x assembler-with-cpp # Specify the source language: C, C++, Objective-C, or assembly.
    --specs=nano.specs # include path and lib params to use newlib-nano and replaces e.g. -lc with -lc_nano see -lc below
)
add_compile_options("$<$<COMPILE_LANGUAGE:ASM>:${ASM_ONLY_TARGET_FLAGS}>")

# https://linux.die.net/man/1/ld linux linker options
# https://gcc.gnu.org/onlinedocs/gcc/Spec-Files.html
set(LINK_FLAGS
    -T ${LINKER_SCRIPT}
    --specs=nosys.specs # system calls should be implemented as stubs
    --specs=nano.specs # include path and lib params to use newlib-nano and replaces e.g. -lc with -lc_nano see -lc below
    -Wl,-Map=BareMetalWorkshop.map # a linker map - I can't find this one, are we writing it?
    -Wl,--gc-sections # Garbage collect sections - see ffunction-sections fdata-sections in the compiler options below
    -static # Prevents linking with shared libraries
    -Wl,--start-group 
    -lc # CANT FIND
    -lm # CANT FIND
    -Wl,--end-group
)
add_link_options("${TARGET_FLAGS}")
add_link_options("${LINK_FLAGS}")

# optimising compilation
# https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
# https://gcc.gnu.org/onlinedocs/gcc/Developer-Options.html
# https://gcc.gnu.org/onlinedocs/gcc/Overall-Options.html
set(GENERAL_C_CXX_FLAGS
    -ffunction-sections
    # Goes with the above flag Place each function or data item into its own section in the output file if the target supports arbitrary sections. 
    # The name of the function or the name of the data item determines the section’s name in the output file.
    -fdata-sections 
    -fstack-usage # Makes the compiler output stack usage information for the program, on a per-function basis
    # Omit the frame pointer in functions that don’t need one. This avoids the instructions to save, set up and 
    # restore the frame pointer; on many targets it also makes an extra register available.
    -fomit-frame-pointer
    -pipe # Use pipes rather than temporary files for communication between the various stages of compilation.
    # https://gcc.gnu.org/onlinedocs/gcc/MIPS-Options.html
    # Disable (enable) direct unaligned access for MIPS Release 6.
    -mno-unaligned-access
)

set(GENERAL_CXX_ONLY_FLAGS
    # https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_exceptions.html
    # Turns off exceptions
    -fno-exceptions
    # https://gcc.gnu.org/onlinedocs/gcc/C_002b_002b-Dialect-Options.html
    # Disable generation of information about every class with virtual functions for use by the C++ run-time type identification features (dynamic_cast and typeid)
    -fno-rtti
    # Do not emit the extra code to use the routines specified in the C++ ABI for thread-safe initialization of local statics.
    -fno-threadsafe-statics
)

add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:${GENERAL_C_CXX_FLAGS}>")
add_compile_options("$<$<COMPILE_LANGUAGE:CXX>:${GENERAL_CXX_ONLY_FLAGS}>")

# https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
set(WARNING_FLAGS
    # This enables all the warnings about constructions that some users consider questionable, 
    # and that are easy to avoid (or modify to prevent the warning), even in conjunction with macros
    -Wall
    # Make the specified warning into an error (variable length array?)
    -Werror=vla
    # This enables some extra warning flags that are not enabled by -Wall
    -Wextra
    # Issue all the warnings demanded by strict ISO C and ISO C++;
    -Wpedantic
    # Warn if a global function is defined without a previous declaration.
    -Wmissing-declarations
    # When compiling C, give string constants the type const char[length] so that copying the address of one into a non-const char * pointer produces a warning
    -Wwrite-strings
    # Warn whenever a pointer is cast such that the required alignment of the target is increased. 
    # For example, warn if a char * is cast to an int * regardless of the target machine.
    -Wcast-align=strict
    # Check calls to printf and scanf, etc., to make sure that the arguments supplied have types appropriate to the format string specified plus additional format checks
    -Wformat=2
    # Warn if floating-point values are used in equality comparisons.
    -Wfloat-equal
    # Warn about function pointers that might be candidates for format attributes. 
    -Wmissing-format-attribute
    # Warn if anything is declared more than once in the same scope, even in cases where multiple declaration is valid and changes nothing.
    -Wredundant-decls
)

set(WARNING_FLAGS_C_ONLY
    # Warn if a function is declared or defined without specifying the argument types
  -Wstrict-prototypes
  # Warn if a global function is defined without a previous prototype declaration. 
  -Wmissing-prototypes
  # Warn when a function call is cast to a non-matching type
  -Wbad-function-cast
)

add_compile_options("$<$<COMPILE_LANGUAGE:C,CXX>:${WARNING_FLAGS}>")
add_compile_options("$<$<COMPILE_LANGUAGE:C>:${WARNING_FLAGS_C_ONLY}>")

set(C_CXX_DEBUG_ONLY_FLAGS
    -O0
    -g3
)

set(C_CXX_RELEASE_ONLY_FLAGS
    -O3
)

add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:C,CXX>,$<CONFIG:DEBUG>>:${C_CXX_DEBUG_ONLY_FLAGS}>")
add_compile_options("$<$<AND:$<COMPILE_LANGUAGE:C,CXX>,$<CONFIG:RELEASE>>:${C_CXX_REALEASE_ONLY_FLAGS}>")

