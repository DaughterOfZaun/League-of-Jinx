import re
from wordsegment import load, segment

flat_map = lambda f, xs: [y for ys in xs for y in f(ys)]

load()

mistakes = {}

with open('./files.list.txt', 'r') as f:
    ls = f.readlines()
    for l in ls:
        fn = (l.split('/')[-1]).split('.')[0]
        
        fnp = fn
        fnp = re.sub('[^a-zA-Z]+', '\n', fnp)
        fnp = re.sub('([a-z])([A-Z])', '\\1\n\\2', fnp)
        fnp = re.sub('([A-Z])([A-Z][a-z])', '\\1\n\\2', fnp)
        fnp = fnp.strip().split('\n')

        #fnq = ''.join(fnp)
        #fnq = segment(fnq)
        
        #fnq = flat_map(segment, fnp)

        for w in fnp:
            if w in mistakes:
                continue

            ws = segment(w)
            if len(ws) != 1:
                print(fn, w, '->', ws)
            
            mistakes[w] = []

        #if len(fnp) != len(fnq):
        #    print(fn, fnp, fnq)
