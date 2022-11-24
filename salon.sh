#!/bin/bash
#coneccion a la db salon
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
#Encabezado
echo -e "\n~~~~~ MY SALON ~~~~~\n"

echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU(){
  if [[ $1 ]]
    then
      echo -e "\n$1"
  fi
  #se crea la variable AVAILABLE_SERVICES
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #se llama a la variable. Si es nula entonces... "Sorry..."
  if [[ -z $AVAILABLE_SERVICES ]]
    then
      echo "Sorry, we don't have any service right now"
      #si la variable no es nula
    else
      #while para crear el menu de los servicios
      echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
      do
        echo "$SERVICE_ID) $NAME"
      done
      read SERVICE_ID_SELECTED
      #if para asegurar que lo ingresado es un numero
      if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
        #si no es un numero...entonces
        then
          MAIN_MENU "Insert a number available, please"
        else
          NUM_SERV_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          NAME_SERV=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
          if [[ -z $NUM_SERV_AVAILABLE ]]
            then
              MAIN_MENU "I could not find that service. What would you like today?"
            else
              echo -e "\nWhat your phone number?"
              read CUSTOMER_PHONE
              CUSTOMER_NAME=$($PSQL "SELECT name FROM  customers WHERE phone = '$CUSTOMER_PHONE'")
              if [[ -z $CUSTOMER_NAME ]]
                then
                  echo -e "\nWhat's your name?"
                  read CUSTOMER_NAME
                  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
              fi
              echo -e "\nWhat time would you like your$NAME_SERV, $CUSTOMER_NAME?"
              read SERVICE_TIME
              CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
              if [[ $SERVICE_TIME ]]
                then
                  INSERT_SERV_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
                  if [[ $INSERT_SERV_RESULT ]]
                    then
                      echo -e "\nI have put you down for a$NAME_SERV at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
                  fi
              fi
            
          fi
      
      fi

  fi



}

MAIN_MENU
