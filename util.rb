# coding: utf-8

require "date"
def olderThan03212020 (filename)
  if (filename =~ /0[12]-\d\d-2020.csv/ ||
      filename =~ /03-[01]\d-2020.csv/ ||
      filename =~ /03-2[01]-2020.csv/)
    return true
  else
    return false
  end
end

def mmddyyyy2date(str)
  if (str =~ /^\d\d\d\d\//)
    if (/(\d+)\/(\d+)\/(\d+)/ =~ str)
    return Date.new($1.to_i, $2.to_i, $3.to_i)
    end
  else
    if (/(\d+)\/(\d+)\/(\d+)/ =~ str)
      return Date.new($3.to_i, $1.to_i, $2.to_i)
    end
  end
end

def date2mmdd(date)
  return date.strftime("%m/%d")
end

def date2mmddYY(date)
  return date.strftime("%m/%d/%Y")
end
def date2mmddyy(date)
  return date.strftime("%0m/%d/%y").gsub(/^0/, "").gsub(/\/0/, "/")
end
  

def readHtml(filename, replace)
  File.open(filename, "r:UTF-8") do |body|
    body.each_line do |oneline|
      replace.each do |str, replace|
        oneline = oneline.gsub(/#{str}/, replace)
      end
      puts oneline
    end
  end
end

$pref_en = {"北海道": "Hokkaido",
           "青森県": "Aomori",
           "岩手県": "Iwate",
           "宮城県": "Miyagi",
           "秋田県": "Akita",
           "山形県": "Yamagata",
           "福島県": "Fukushima",
           "茨城県": "Ibaraki",
           "栃木県": "Tochigi",
           "群馬県": "Gunma",
           "埼玉県": "Saitama",
           "千葉県": "Chiba",
           "東京都": "Tokyo",
           "神奈川県": "Kanagawa",
           "新潟県": "Niigata",
           "富山県": "Toyama",
           "石川県": "Ishikawa",
           "福井県": "Fukui",
           "山梨県": "Yamanashi",
           "長野県": "Nagano",
           "岐阜県": "Gifu",
           "静岡県": "Shizuoka",
           "愛知県": "Aichi",
           "三重県": "Mie",
           "滋賀県": "Shiga",
           "京都府": "Kyoto",
           "大阪府": "Osaka",
           "兵庫県": "Hyogo",
           "奈良県": "Nara",
           "和歌山県": "Wakayama",
           "鳥取県": "Tottori",
           "島根県": "Shimane",
           "岡山県": "Okayama",
           "広島県": "Hiroshima",
           "山口県": "Yamaguchi",
           "徳島県": "Tokushima",
           "香川県": "Kagawa",
           "愛媛県": "Ehime",
           "高知県": "Kochi",
           "福岡県": "Fukuoka",
           "佐賀県": "Saga",
           "長崎県": "Nagasaki",
           "熊本県": "Kumamoto",
           "大分県": "Oita",
           "宮崎県": "Miyazaki",
            "鹿児島県": "Kagoshima",
            "沖縄県": "Okinawa",
            "羽田空港": "Haneda Airport",
            "成田空港": "Narita Airport",
            "関西国際空港": "Kansai Kokusai Airport",
            "中部国際空港": "Chubu Kokusai Airport",
            "不明": "unresolved",
           "東京最大予測": "Tokyo Max",
           "東京平均予測": "Tokyo avg",
           }

$pref_en2ja = {}
$pref_en.each do |p|
  $pref_en2ja[:"#{p[1]}"] = p[0].to_s
end

$pref_latlong = {
  Hokkaido: [43.4672, 43.4672],
  Aomori: [40.7803, 40.7803],
  Iwate: [39.5914, 39.5914],
  Miyagi: [38.4456, 38.4456],
  Akita: [39.7475, 39.7475],
  Yamagata: [38.4464, 38.4464],
  Fukushima: [37.3789, 37.3789],
  Ibaraki: [36.3064, 36.3064],
  Tochigi: [36.6892, 36.6892],
  Gunma: [36.5039, 36.5039],
  Saitama: [35.9967, 35.9967],
  Chiba: [35.5128, 35.5128],
  Tokyo: [35.0183, 35.0183],
  Kanagawa: [35.4142, 35.4142],
  Niigata: [37.5189, 37.5189],
  Toyama: [36.6361, 36.6361],
  Ishikawa: [36.7658, 36.7658],
  Fukui: [35.8467, 35.8467],
  Yamanashi: [35.6122, 35.6122],
  Nagano: [36.13, 36.13],
  Gifu: [35.7775, 35.7775],
  Shizuoka: [35.0169, 35.0169],
  Aichi: [35.0344, 35.0344],
  Mie: [34.5136, 34.5136],
  Shiga: [35.2153, 35.2153],
  Kyoto: [35.2519, 35.2519],
  Osaka: [34.6228, 34.6228],
  Hyogo: [35.0369, 35.0369],
  Nara: [34.3156, 34.3156],
  Wakayama: [33.9094, 33.9094],
  Tottori: [35.3606, 35.3606],
  Shimane: [35.0731, 35.0731],
  Okayama: [34.9008, 34.9008],
  Hiroshima: [34.6036, 34.6036],
  Yamaguchi: [34.1986, 34.1986],
  Tokushima: [33.9181, 33.9181],
  Kagawa: [34.2431, 34.2431],
  Ehime: [33.6219, 33.6219],
  Kochi: [33.4211, 33.4211],
  Fukuoka: [33.5225, 33.5225],
  Saga: [33.2853, 33.2853],
  Nagasaki: [33.2275, 33.2275],
  Kumamoto: [32.615, 32.615],
  Oita: [33.1992, 33.1992],
  Miyazaki: [32.1908, 32.1908],
  Kagoshima: [31.0128, 31.0128],
  Okinawa: [25.7711, 25.7711],
  "Haneda Airport": [35.5448, 139.7672],
  "Narita Airport": [35.7719, 140.3928],
  "Kansai Kokusai Airport": [34.4361, 135.2432],
  "Chubu Kokusai Airport": [34.8592, 136.8163],
}

$color_table = [ #"Red",
  "Blue", "Green", "Black", #"Cyan",
  "Orange", "Purple",
  "maroon", "olive", "fuchsia", #"aqua",
  "lime", "teal",
  "navy", "silver", "gray"]


def index2days(i, lang)
  if (lang == "-en")
    if (i == 0)
      return "0 day"
    elsif (i == 1)
      return "1st day"
    elsif (i == 2)
      return "2nd day"
    elsif (i == 3)
      return "3rd day"
    else
      return "#{i}th day"
    end
  else
    return "#{i}日目"
  end
end

def prefJa2prefEn (pref, lang)
  if (lang == "-en" && $pref_en[:"#{pref}"] != nil)
      return $pref_en[:"#{pref}"]
  else
    return pref
  end
end

def prefen2prefjp (pref, lang)
  if (lang == "" && $pref_en2ja[:"#{pref}"] != nil)
    return $pref_en2ja[:"#{pref}"]
  else
    return pref
  end
end



def pref2latlong (pref)
  if ($pref_latlong[:"#{pref}"] != nil)
    return $pref_latlong[:"#{pref}"]
  else
    return [0, 0]
  end
end
