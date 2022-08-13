# Flutter_Learn_2

Saya membagikan ini untuk sama-sama belajar sambil share. <br>
induk project ada di <b>main.dart</b>

## Flutter Command

`flutter run`   untuk menjalankan flutter project, nnti akan muncul pilihan device <br>
`flutter run -d edge`   untuk menjalankan flutter project ke device [edge]. Untuk ke device lain, ganti dengan nama devicenya

## Realease note
### 27/07/2022
- Pada tahap ini sudah koneksi ke database local menggunakan RestfulApi
- Pada tahap ini merupakan lanjutan dari Flutter_learn_1 <a href="https://github.com/haryo-sk/Flutter_Learn_1"> disini </a>
- Untuk pembuatan RestfulApi, silahkan lihat,copy dan pahami repository Codeigniter_learn_1 <a href="https://github.com/haryo-sk/Codeigniter_Learn_1"> disini </a>
- Menggunakan `SharedPreferences` sebagai fasiliator penyimpanan local storage
- Beberapa file di `Flutter_Learn_1` sudah dihapus karena tidak digunakan lagi. Silahkan copy dan pahami seluruh file dart terbaru di `Flutter_Learn_2`

### 29/07/2022
- pembaruan dari sebelumnya
- Penambahan `CarouselSlider.Builder` beserta indicator page nya, diletakkan pada <b>dashboard.dart</b>

### 13/08/2022
- pembaruan dari sebelumnya
- Penambahan `GridView.Builder` sebagai slider card dibawah CarouselSlider. Gridview ini bisa dirubah horizontal ataupun vertikal, dengan merubah Axis nya.
Untuk contoh code, bisa dilihat, class homepage di <b>dashboard.dart</b>
- Untuk cara agar saat scroll ListView bisa seolah sembunyi dibawah appBar, tambahkan `extendBodyBehindAppBar: true,` dibawah `home: Scaffold`

#Semoga_bermanfaat
