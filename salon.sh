#! /bin/bash

# Define database query function
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Display services
echo "Welcome to the Salon Appointment Scheduler!"
SERVICE_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

show_services() {
  echo "Here are the services we offer:"
  echo "$SERVICE_LIST" | while IFS="|" read SERVICE_ID SERVICE_NAME; do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Appointment scheduler function
make_appointment() {
  show_services

  echo -e "\\nPlease select a service by entering the service number:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\\nInvalid service. Please try again."
    make_appointment
  else
    echo -e "\\nEnter your phone number:"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\\nYou are not in our system. Please enter your name:"
      read CUSTOMER_NAME
      $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    echo -e "\\nEnter the appointment time (e.g., 10:30):"
    read SERVICE_TIME
    $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

    echo -e "\\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

make_appointment
