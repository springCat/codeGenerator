# codeGenerator
##  generater the java bean from mysql

#### write by shell，using

- mysqlclient

- csvkit

- other shell commend


no other dependency，it‘s  easy to apply to generater things by modify the script



usage:

>./gen.sh #tableName    #packageName  #genpath



for example

>./gen.sh t_user org.springcat ~

cat ~/User.java        the result is 

>package org.springcat;
>/**
>
>table_name:t_user
>
>@author springcat
>*/
>
import java.util.Date;
>public class User
>{
>
>  /**
>
>id
>*/
>  private Long id;
>
>  /**
>
>名字
>*/
>  private String name;
>
>  /**
>
>生日
>*/
>  private String birthday;
>}
