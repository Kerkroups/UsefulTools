#!/usr/bin/python3
import sys

file = sys.argv[1]

translation = {}
translation[ord('q')] = 'й'
translation[ord('w')] = 'ц'
translation[ord('e')] = 'у'
translation[ord('r')] = 'к'
translation[ord('t')] = 'е'
translation[ord('y')] = 'н'
translation[ord('u')] = 'г'
translation[ord('i')] = 'ш'
translation[ord('o')] = 'щ'
translation[ord('p')] = 'з'
translation[ord('[')] = 'х'
translation[ord(']')] = 'ъ'
translation[ord('a')] = 'ф'
translation[ord('s')] = 'ы'
translation[ord('d')] = 'в'
translation[ord('f')] = 'а'
translation[ord('g')] = 'п'
translation[ord('h')] = 'р'
translation[ord('j')] = 'о'
translation[ord('k')] = 'л'
translation[ord('l')] = 'д'
translation[ord(';')] = 'ж'
translation[ord('\'')] = 'э'
translation[ord('z')] = 'я'
translation[ord('x')] = 'ч'
translation[ord('c')] = 'с'
translation[ord('v')] = 'м'
translation[ord('b')] = 'и'
translation[ord('n')] = 'т'
translation[ord('m')] = 'ь'
translation[ord(',')] = 'б'
translation[ord('.')] = 'ю'


with open(file, 'r') as f:
    for line in f:
        s1 = line.translate(translation)
        print(s1.replace("\n", ""))
        

