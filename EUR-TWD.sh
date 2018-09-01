#!/bin/bash
#名稱		版本	日期		作者	備註
#查日元匯率	v1	20170518	arthur	引用臺銀數據
#查歐元匯率	v1.1	20180719	arthur	修正測試中功能把<> tag移除,預計日後導入扣除手續費，令符合實務
#		v1.2	20180720	arthur	新增手續費選項，目前取前三名
#		v1.3	20180720	arthur	優化界面，便於手機版閱讀
#		v1.4	20180722	arthur	新增免手續費，和開戶免手續費，預計導入扣手續費的比較
#		v2	20180722	arthur	新增扣除手續費後比較
#		v2.1	20180722	arthur	註解"有帳戶免扣手續費功能"，因為用不到；預計導入免手續費和扣100實際價差(心情好的話)


echo '=============不計手續費============='
curl -sk https://www.findrate.tw/EUR/#.WzrWutIzY2w |egrep -B1 '(需要買歐元|歐元換成台幣)'|awk -F '>' '{print $2}'| sed 's/<.*//g' |sed 's/。.*/。/g'
echo ' '
echo '=============臺銀資料============='
echo -n 臺銀:歐元'現鈔賣出價格: '
curl -sk https://www.findrate.tw/bank/29/#.Wv0TO0iFM2w |grep -A 3 EUR |tail -n1 | awk '{print $4}'|cut -c 15-25 |sed 's/<\/td>//g'

echo -n '1000元可換多少歐元: '
curl -sk https://www.findrate.tw/converter/TWD/EUR/1000/#.WzraIdIzY2w |grep -A2 '00 TWD' |tail -n1 |awk '{print $3}' |cut -c 13-19

#Sfin=$(sed -n '/>--</=' test.html |tail -n1|awk '{print $1+7,$1+10,$1+14}'|sed 's/ /,/g')
#sed -n ''$Sfin' p' test.html
curl -sk 'https://www.findrate.tw/EUR/?type=EUR&order=out1&by=asc' > test.html
echo ' '
echo -n '===最便宜價格排序===第1名 : '
S7=$(sed -n '/>--</=' test.html |tail -n1 |awk '{print $1+7}')
S10=$(sed -n '/>--</=' test.html |tail -n1 |awk '{print $1+10}')
S14=$(sed -n '/>--</=' test.html |tail -n1 |awk '{print $1+14}')
sed -n ''$S7' p' test.html | awk -F '>' '{print $3}'|sed s/\<.*//g
echo -n '金額: '
sed -n ''$S10' p' test.html | awk -F '>' '{print $2}'|sed -e s/\<.*//g -e 's/$/ 元/g'
echo -n '手續費: '
sed -n ''$S14' p' test.html | awk -F '>' '{print $2}'|sed -e s/\<.*//g -e 's/ //g'

echo ' '
echo -n '===免手續費=== : '
S7=$(sed -n '/>--</=' test.html |tail -n1 |awk '{print $1+7}')
sed -n ''$S7',260 p' test.html  |grep -n -B7 ' 免手'|sed -n '1p' |awk -F '>' '{print $3}' |sed 's/<.*//'
echo -n '金額: '
sed -n ''$S7',260 p' test.html  |grep -n -B7 ' 免手'|sed -n '4p' |awk -F '>' '{print $2}' |sed -e 's/<.*//' -e 's/$/ 元/g'
echo -n '手續費: '
sed -n ''$S7',260 p' test.html  |grep -n -B7 ' 免手'|sed -n '8p' |sed -e 's/^[0-9].*">//g' -e 's/<\/td>//g' -e 's/ //g'

#echo ' '
#echo -n '===開戶免手續費=== : '
#SAccNo=$(sed -n ''$S7',800 p' test.html  |grep -n '免'| grep -v '> 免手續費 <' |head -n1 |cut -d ':' -f1| awk '{print $1+ '$S7' -8}')
#sed -n ''$SAccNo',800 p' test.html  |grep -n -B7 '免'|sed -n '1p' | awk -F '>' '{print $3}' |sed 's/<.*//'
#echo -n '金額: '
#sed -n ''$SAccNo',800 p' test.html  |grep -n -B7 '免'|sed -n '4p' |awk -F '>' '{print $2}'|sed 's/<.*/ 元/g'
#echo -n '手續費: '
#sed -n ''$SAccNo',800 p' test.html  |grep -n -B7 '免'|sed -n '8p' |sed -e 's/^[0-9].*">//g' -e 's/<\/td>//g' -e 's/ //g'

echo ' '
echo '===換多少錢被扣手續費才划算？==='
echo '以"第1名"-"免手續費"為例'
#c1=第1名(但會扣手續費的)
c1=$(sed -n ''$S10' p' test.html | awk -F '>' '{print $2}'|sed -e s/\<.*//g)
echo -n "$c1="
sed -n ''$S7' p' test.html | awk -F '>' '{print $3}'|sed s/\<.*//g
#c2=免手續費最便宜價
c2=$(sed -n ''$S7',260 p' test.html  |grep -n -B7 ' 免手'|sed -n '4p' |awk -F '>' '{print $2}' |sed -e 's/<.*//')
echo -n "$c2="
sed -n ''$S7',260 p' test.html  |grep -n -B7 ' 免手'|sed -n '1p' |awk -F '>' '{print $3}' |sed 's/<.*//'
echo ' '
echo -n '要換超過'
#扣手續費則錢要超過$Dollars才划算
#$Dollars/$c2=($Dollars-100)/$c1
#$c2*$Dollars-100*$c2=$c1*$Dollars
#($c2-$c1)$Dollars=$c2*100
#$Dollars=$c2*100/($c2-$c1)
#顯示9位數(5整數+1小數點+小數點後4位數)
echo -n $c1 $c2 | awk '{printf ("%9.4f\n", $2*100/($2-$1))}' |sed 's/$/元才划算。(小數點後4位數)/g'

#參考資料
#顯示第幾到第幾行 sed -n '11,20 p' test.html
#匯率網，有排序的 curl -s 'http://www.findrate.tw/EUR/?type=EUR&order=out1&by=asc' > test.html
#awk參考資料： http://netkiller.sourceforge.net/zh-tw/shell/awk.html
