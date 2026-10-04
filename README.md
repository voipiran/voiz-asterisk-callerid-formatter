# Issabel/Freepbx CalleridFormatter
Translation:

Caller number correction, suitable for local landlines in Iran: Sometimes, incoming numbers are missing the initial "0" or include extra numbers and symbols like "98." With this script, the incoming caller ID is corrected as it enters your telephony system. This script is crucial for reporting modules and applications.

اصلاح شماره تماس گیرنده، مناسب برای خطوط شهری داخلی ایران، برخی مواقع شماره های ورودی بدون 0 اولیه یا همراه با عدد ها وعلائم اضافی مثل 98 است، با این اسکریپت در ورودی سیستم تلفنی شما کالر آی دی ورودی اصلاح می شود. این اسکریپ برای ماژول ها و برنامه های گزارشگیری بسیار حیاتی است.
.
## Instalation (راهنمای نصب)

#1. run on your Linux CLI.

## 1. دستور زیر را بر روی کنسول لینوکس ایزابل خود اجرا کنید.
```
curl -L -o voiz-asterisk-callerid-formatter.zip https://github.com/voipiran/voiz-asterisk-callerid-formatter/archive/main.zip \
&& unzip -o voiz-asterisk-callerid-formatter.zip \
&& cd voiz-asterisk-callerid-formatter-main \
&& chmod 755 install.sh \
&& ./install.sh -y
```


#2. Change the Trunk incoming context to   context=to-cidformatter

## 2. در تعریف ترانک ورودی شهری خود 
## کانتکس پیش فرض رابه context=to-cidformatter تغییر دهد.

## Give a Star! ⭐ یک ستاره با ما بدهید
If you like this project or plan to use it in the future, please give it a star. Thanks 🙏
