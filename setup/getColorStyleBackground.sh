#!/bin/bash

export NC='\033[0m'       # Text Reset

function getColorStyleBackground()
{
	txtcolor="30"
    case $1 in
        "Black" )  txtcolor="30" ;;
        "Red" )    txtcolor="31" ;;
        "Green" )  txtcolor="32" ;;
        "Yellow" ) txtcolor="33" ;;
        "Blue" )   txtcolor="34" ;;
        "Purple" ) txtcolor="35" ;;
        "Cyan" )   txtcolor="36" ;;
        "White" )  txtcolor="37" ;;
    esac

	style="0"
    case $2 in
        "Bold"      ) style="1" ;;
        #"Dim"       ) style="2" ;;
        #"Underline" ) style="4" ;;
        #"Blink"     ) style="5" ;;
        "Reverse"   ) style="7" ;;
        "Hidden"    ) style="8" ;;
    esac

    background="40"
    case $3 in
        "Black" )  background="40" ;;
        "Red" )    background="41" ;;
        "Green" )  background="42" ;;
        "Yellow" ) background="43" ;;
        "Blue" )   background="44" ;;
        "Purple" ) background="45" ;;
        "Cyan" )   background="46" ;;
        "White" )  background="47" ;;
    esac

    back="\033["
    back+=$style
    back+=";"
    back+=$txtcolor
    back+=";"
    back+=$background
    back+="m"


    echo $back
}

export -f getColorStyleBackground
