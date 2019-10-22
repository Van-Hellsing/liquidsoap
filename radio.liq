#!/usr/bin/liquidsoap

# пути к папкам
mus = "/mnt/hdd/Mp3"
teh = "/mnt/hdd/Mp3.1"

# загружаем плейлисты
ino = "#{mus}/иностранное"
rus = "#{mus}/русское"
muz = "#{mus}/music"

# базовая информация о выводимом потоке для icecast
out = output.icecast(
	encoding = "UTF-8",	# кодировка
	host = "localhost",	# хост с icecast
	port = 8000,
	genre = "various",
	user = "source",
	password = "radio_01"
)

# логи
set("log.file.path","/var/log/liquidsoap/liquidsoap.log") # путь к файлу лога
set("log.level", 3) # уровень логирования

#Set tag encoding
set("tag.encodings",["UTF-8"])

# функция динамического генерирования названия плейлиста часов
# часы получаем из шелла 
def get_time()
   log("..........1")
   t = get_process_output("echo -n `expr $(date +%_H) + 1`")
   log("t.....#{t}")
   t = "#{teh}/clock/hour_#{t}.mp3" 
   log("t.....#{t}")
#   tt = localtime(time(), fun (~sec,~min,~hour,~mday,~mon,~year,~wday,~yday,~isdst) -> min)
#   log("tt.....#{tt}")
   request.create(t)
end

def radio_dev(a, b, c)
    pls_a = playlist(reload=1, reload_mode="rounds", mode="randomize", a)
    pls_b = playlist(reload=1, reload_mode="rounds", mode="randomize", b)
    pls_c = playlist(reload=1, reload_mode="rounds", mode="randomize", c)
    #перемешиваем
    pls_0 = rotate(weights = [1, 1, 1], [pls_a, pls_b, pls_c])

    pls = mksafe(normalize(pls_0))

    # кросфейдинг, плавное затухание/нарастание
    radio_pre = crossfade(start_next=5., fade_out=5., fade_in=5., pls)
    ##radio_pre = smart_crossfade(music_pre)
    # часы
    hours = switch([({0m0s}, request.dynamic(get_time))])
    #hours = switch([({0s},playlist("#{teh}/clock/minute_#{get_time}.mp3"))])
   #minute = single(#{teh}/clock/minute_30.mp3")
   #hours = switch([({0s},minute)])
# строка для теста часов
#    hours = switch([({0s},hour)])
    add([radio_pre, amplify(5.,hours)])
end



radio_1 = radio_dev(ino, rus, muz)
radio_2 = radio_dev(ino, rus, muz)
radio_3 = radio_dev(ino, rus, muz)
radio_4 = radio_dev(ino, rus, muz)

out(%vorbis(channels = 2, quality = 0.2),
        description = "radio r_1",
	name = "Радио r_1",
        mount = "r_1",
        radio_1
)
out(%vorbis(channels = 2, quality = 0.2),
        description = "radio r_2",
        name = "Радио r_2",
        mount = "r_2",
        radio_2
)
out(%vorbis(channels = 2, quality = 0.2),
        description = "radio r_3",
        name = "Радио r_3",
        mount = "r_3",
        radio_3
)
out(%vorbis(channels = 2, quality = 0.2),
        description = "radio r_4",
        name = "Радио r_4",
        mount = "r_4",
        radio_4
)
output.harbor(
        %vorbis(channels = 2, quality = 0.2),
        port = 8023,
        encoding = "UTF-8",
        id = "radio id",
        #description = "radio r1_desk",
        #name = "r1_8023",
        mount = "r1",
        radio_1
)

