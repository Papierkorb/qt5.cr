module Qt
  class Application
    @argv : UInt8** = ARGV_UNSAFE
    @argc : Int32 = ARGC_UNSAFE

    def initialize
      # The `0x50901` magic refers to the Qt library that was linked against.
      # It's a version identifier.  Even better, this argument is completely
      # undocumented :)
      @unwrap = Binding.bg_QApplication_CONSTRUCT_int_R_char_XX_int(pointerof(@argc), @argv, 0x50901)
    end
  end
end
