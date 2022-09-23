echo "running post-wrapper-hook"

@mini_compile_commands_client@ $(pwd) \
   ${extraBefore+"${extraBefore[@]}"} \
   ${params+"${params[@]}"} \
   ${extraAfter+"${extraAfter[@]}"}
