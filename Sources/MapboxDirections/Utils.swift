#if os(Linux)
import Glibc
#else
import Darwin
#endif

struct StderrOutputStream: TextOutputStream {
    mutating func write(_ string: String) { fputs(string, stderr) }
}
var errorStream = StderrOutputStream()
