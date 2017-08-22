module Qt
  class Application
    @argv : UInt8** = ARGV_UNSAFE
    @argc : Int32 = ARGC_UNSAFE

    def initialize
      @unwrap = Binding.bg_QApplication_CONSTRUCT_int_R_char_XX(pointerof(@argc), @argv)
    end
  end
end
