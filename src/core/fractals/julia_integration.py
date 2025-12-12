import numpy as np
import matplotlib.pyplot as plt

def julia_set(h, w, c, max_iter):
    y, x = np.ogrid[-1.4:1.4:h*1j, -1.4:1.4:w*1j]
    z = x + y*1j
    divtime = max_iter + np.zeros(z.shape, dtype = int)

    for i in range(max_iter):
        z = z**2 + c
        diverge = z*np.conj(z) > 2**2
        div_now = diverge & (divtime == max_iter)
        divtime[div_now] = i
        z[diverge] = 2

    return divtime

def integrate_with_bazinga_pattern(pattern_id, c=-0.7+0.27j):
    julia_data = julia_set(1000, 1000, c, 100)
    plt.figure(figsize=(10, 10))
    plt.imshow(julia_data, cmap = 'hot')
    plt.title(f'BAZINGA Pattern ID: {pattern_id} - Julia Set')
    plt.axis('off')
    plt.savefig(f'output/pattern_{pattern_id}_julia.png')
    return julia_data
