#INSTALL MAIN SCRIPT AS system 
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/MAIN.sh && chmod +x MAIN.sh

cp MAIN.sh /bin/goldenONE && chmod +x /bin/goldenONE

 --- now you can run goldenONE command everywhere

# AUTOMATED SCRIPT INSTALL SOFTETHER LATEST STABLE RELEASE

curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/build_se_stable.sh && chmod +x build_se_stable.sh

./build_se_stable.sh



## build from source , softether
curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/build_se_fromsource.sh

chmod +x build_se_fromsource.sh

./build_se_fromsource.sh

# BETA - TEST

curl -O https://raw.githubusercontent.com/ExtremeDot/golden_one/master/softetherv5.sh

chmod +x softetherv5.sh

./softetherv5.sh
