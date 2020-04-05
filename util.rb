# coding: utf-8

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
