// Expected failure: a skipped arbitrary String cannot be reconstructed.
import Coder

typealias Invalid = Skip<Int, String>.Coder<
    Coder<Substring, Int, String, Never>,
    Coder<Substring, String, String, Never>, Never
>
