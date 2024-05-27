# Cheat Code
Cheat code dapat diaktifkan dan dinonaktifkan dengan sequence berikut:
↑↑↓↓←→←→

Cheat code ini akan membuat attack charge player selalu menyala sehingga player tidak perlu parry 5 kali sebelum bisa menyerang.

# Polishing
1. Black screen transition tepat sebelum cinematic mulai awalnya tidak langsung hitam sehingga ada sedikit flickering di awal. Diperbaiki dengan membuat default valuenya hitam.
2. Membuang label di atas enemy yang awalnya hanya digunakan untuk debugging.
3. Particle api awalnya dirender di belakang air sehingga tidak kelihatan. Diperbaiki dengan sorting offset dari particle. 
4. Fix player-win cinematic di mana orb api masih terlihat di tangan musuh padahal seharusnya tidak terlihat.
5. Merapikan kode yang mengatur particle attack charge player agar mengakomodasi cheat baru.
6. Memperbaiki animasi in general untuk cinematic enemy yang awalnya terkadang ada prop yang muncul hilang tidak sesuai keinginan. Hal ini diperbaiki dengan mengatur animation track terkait visibility menjadi continuous melainkan discrete. Masalah dengan discrete terjadi ketika ada animation blending sehingga bisa saja ada titik visibility yang terlewat di animation tracknya.