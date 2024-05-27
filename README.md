# Cheat Code
Cheat code dapat diaktifkan dan dinonaktifkan dengan sequence berikut:
↑↑↓↓←→←→

Cheat code ini akan membuat attack charge player selalu menyala sehingga player tidak perlu parry 5 kali sebelum bisa menyerang.

# Polishing
1. Black screen transition tepat sebelum cinematic mulai awalnya tidak langsung hitam sehingga ada sedikit flickering di awal. Diperbaiki dengan membuat default valuenya hitam.
2. Membuang label di atas enemy yang awalnya hanya digunakan untuk debugging.
3. Particle api awalnya dirender di belakang air sehingga tidak kelihatan. Diperbaiki dengan sorting offset dari particle. 