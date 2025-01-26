from utils.static_tuple import StaticTuple
from memory import UnsafePointer


fn binary_to_int(s: String) -> Int:
    var result: Int = 0
    for i in range(len(s)):
        var digit = ord(s[i]) - ord('0')
        result = result * 2 + digit
    return result

struct HammingCode:
    var data: String
    var redundant_bits: Int

    fn __init__(mut self, data: String) raises:
        self.data = data
        self.redundant_bits = self.calc_redundant_bits(len(data))


    @staticmethod
    fn calc_redundant_bits(m: Int) -> Int:
        var r: Int = 0
        while True:
            if (1 << r) >= m + r + 1:
                return r
            r += 1

    fn pos_redundant_bits(self) -> String:
        var m = len(self.data)
        var j: Int = 0
        var k: Int = 1
        var res = String("")

        for i in range(1, m + self.redundant_bits + 1):
            if i == (1 << j):
                res += "0"
                j += 1
            else:
                res += self.data[m - k]
                k += 1
        return res[::-1]

    fn calc_parity_bits(self, arr: String) raises -> String:
        var n = len(arr)
        var result = arr

        for i in range(self.redundant_bits):
            var val: Int = 0
            for j in range(1, n + 1):
                if (j & (1 << i)) == (1 << i):
                    val ^= atol(arr[n - j])

            var pos = n - (1 << i)
            result = result[:pos] + str(val) + result[pos + 1 :]

        return result

    fn detect_error(self, received: String) raises -> Int:
        var n = len(received)
        var res: Int = 0

        for i in range(self.redundant_bits):
            var val: Int = 0
            for j in range(1, n + 1):
                # print("333 :::::::::::::::::::: ", n, j,received[n - j])
                if (j & (1 << i)) == (1 << i):
                    val ^= atol(received[n - j])

            res += val * (10**i)

        print("::::::::::::::::", binary_to_int(str(res)))
        return binary_to_int(str(res))

    fn encode(self) raises -> String:
        var positioned = self.pos_redundant_bits()
        return self.calc_parity_bits(positioned)

    fn check_error(self, received: String) raises -> Tuple[Bool, Int]:
        print("11 :::", received)
        var error_pos = self.detect_error(received)
        print("22 :::", error_pos)

        if error_pos == 0:
            return (False, 0)
        return (True, len(received) - error_pos + 1)

    fn correct_error(self, received: String) raises -> String:
        var error_result = self.check_error(received)
        var has_error = error_result.get[0, Bool]()
        var error_pos = error_result.get[1, Int]()
        if not has_error:
            return received

        var pos = error_pos - 1
        return (
            received[:pos]
            + ("0" if received[pos] == "1" else "1")
            + received[pos + 1 :]
        )


fn main():
    try:
        # Example usage
        var data = "1011001"
        var hamming = HammingCode(data)

        # Encode data
        var encoded = hamming.encode()
        print("Original data:", data)
        print("Encoded data:", encoded)

        # Simulate error by flipping a bit
        var received = "11101001110"  # Error in 10th position

        var error_result = hamming.check_error(received)
        var has_error = error_result.get[0, Bool]()
        var error_pos = error_result.get[1, Int]()

        if has_error:
            print("Error detected at position", error_pos, "from the left")
            var corrected = hamming.correct_error(received)
            print("Corrected data:", corrected)
        else:
            print("No error detected in the received message")

    except Error:
        print("An error occurred")

