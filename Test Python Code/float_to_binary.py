# code from https://stackoverflow.com/questions/8751653/how-to-convert-a-binary-string-into-a-float-value
# 
# Used to create binary representations of floats for testing the SystemVerilog floating point code
#

from codecs import decode
import struct

# returns the float representation of a binary string


def bin_to_float(b, num_of_bytes):
    t = int_to_bytes(int(b, 2), num_of_bytes)
    # print(t)
    return struct.unpack('>f', t)[0]


def int_to_bytes(n, length):
    return decode('%%0%dx' % (length << 1) % n, 'hex')[-length:]


def float32_to_bin(value):
    [d] = struct.unpack('>L', struct.pack('>f', value))
    return '{:032b}'.format(d)


def float64_to_bin(value):
    [d] = struct.unpack('>Q', struct.pack('>d', value))
    return '{:064b}'.format(d)


if __name__ == '__main__':

    for f in 0.0,-1,1,-2, 2,4,6:
        print('Test value: %f' % f)
        binary = float32_to_bin(f)
        print('\tFloat to binary: %r' % binary)
        print('\tLength is: {:d}'.format(len(binary)))
        float_result = bin_to_float(binary, 4)
        print('\tBinary to float: %f' % float_result)
        dV = f-float_result
        print('\tDifference is: %f\n' % dV)

    # for f in range(-20,20,5):
    #     for j in range(-25,25,9):
    #         print("'b{:s},'b{:s},".format(float32_to_bin(f/10.0),float32_to_bin(j/10.0)))

    # for f in range(-20,20,5):
    #     for j in range(-25,25,9):
    #         print("'b{:s},".format(float32_to_bin((f+j)/10.0)))




        
