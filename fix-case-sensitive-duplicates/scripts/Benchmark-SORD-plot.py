#!/usr/bin/env python

data = [
    [
        7,
        [
            3.50016331673, 7.37909364700, 8.02381229401, 8.01285839081,
            9.77704334259, 9.15692901611, 8.73682498932, 7.93067312241
        ],
    ],
    [
        4.202,
        [
            2.06499981880, 2.08285713196, 2.18571448326, 2.19214320183,
            2.19214320183, 2.19357180595, 2.19500041008, 2.19714307785
        ],
    ],
    [
        9.8592,
        [
            3.56500029564, 3.61142873764, 3.63214302063, 3.63357162476,
            3.63428616524, 3.63428616524, 3.63428616524, 3.63428568840,
            3.63285756111
        ]
    ]
]

# setup
path = []
text = []
dx, dy = 48, -24
nx, ny = 8, 12

# axes
X = dx * nx
Y = dy * ny
U = dx
V = dy * 2
M = nx
N = ny // 2
path += [
    '<path fill="none" stroke="currentColor" stroke-width="1" d="',
    'M0 0h%sv%sh%sz' % (X, Y, -X),
    'M0 0' + ('m%s -4v4' % U * (M - 1)),
    'M0 0' + ('m4 %sh-4' % V * (N - 1)),
    'M0 %s' % Y + ('m%s 4v-4' % U * (M - 1)),
    'M%s 0' % X + ('m-4 %sh4' % V * (N - 1)),
    '" />'
]

# data
marker = 'square'
for tflops, tt in data:
    x = 0
    d = 'M0 %.1f' % (dy * tt[0])
    for t in tt[1:]:
        x += dx
        y = dy * t
        d += ' %.0f %.1f' % (x, y)
    a = '<text x="%s" y="%s">%.0fTFlops</text>' % (x, y + 24, tflops)
    text.append(a)
    path.append(
        '<path fill="none" stroke="currentColor" stroke-width="3"'
        ' marker-start="url(#%s)"' % marker +
        ' marker-mid="url(#%s)"' % marker +
        ' marker-end="url(#%s)"' % marker +
        ' d="%s" />' % d
    )
    marker = 'circle'

# axes text
for i in range(0, N + 1, 2):
    y = V * i + 6
    t = 2 * i
    a = '<text x="-8" y="%s" text-anchor="end">%s</text>' % (y, t)
    text.append(a)
for i in range(0, nx + 1):
    x = dx * i
    if i > 4:
        t = '%sk' % (4 ** (i - 5))
    else:
        t = 4 ** i
    a = '<text x="%s" y="20">%s</text>' % (x, t)
    text.append(a)

# labels
for x, y, u, v, t in [
    (4,  12, 0, -12, 'Runtime/step (s)'),
    (4, 9.8, 0, -12, 'TACC Ranger (8M elem/core)'),
    (4, 3.6, 0, -16, 'ALCF Intrepid (1M elem/core)'),
    (4, 2.2, 0,  24, 'ALCF Vesta (1M elem/core)'),
    (4,   0, 0,  40, 'Cores'),
]:
    x = x * dx + u
    y = y * dy + v
    s = '<text x="%.0f" y="%.0f">' % (x, y) + t + '</text>'
    text.append(s)

# SVG output
x = 64 + X
y = 80 - Y
out = [
    '<svg width="%s" height="auto"' % x +
    ' viewBox="%s %s %s %s"' % (-32, Y - 32, x, y) +
    ' fill="#fff" stroke="#fff"'
    ' xmlns="http://www.w3.org/2000/svg">',
    '<defs>',
    '<marker id="circle"'
    ' refX="4" refY="4" markerWidth="8" markerHeight="8">',
    '<circle stroke="currentColor" stroke-width="1" r="1" cx="4" cy="4"/>',
    '</marker>',
    '<marker id="square"'
    ' refX="4" refY="4" markerWidth="8" markerHeight="8">',
    '<path stroke="currentColor" stroke-width="1" d="M3 3h2v2h-2z" />',
    '</marker>',
    '</defs>'
] + path + [
    '<g fill="none" stroke-width="8" font-size="16" text-anchor="middle"'
    ' font-family="-apple-system, sans-serif">'
] + text + [
    '</g>',
    '<g fill="currentColor" stroke="none" font-size="16" text-anchor="middle"'
    ' font-family="-apple-system, sans-serif">'
] + text + [
    '</g>',
    '</svg>'
]

out = '\n'.join(out) + '\n'
out = out.encode('utf-8')
open('SORD-Benchmark.svg', 'w').write(out)
