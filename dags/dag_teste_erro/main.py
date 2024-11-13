from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.dummy import DummyOperator
from airflow.operators.python import PythonOperator

# Função Python simples para a DAG
def print_hello():
    """
    This function prints a greeting message "Hello from Airflow!", 
    pauses execution for 60 seconds, and then prints "Finish task".
    """
    from time import sleep
    print("Hello from Airflow Error Task!")
    sleep(120)
    return 1/0

# Configuração padrão da DAG
default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 0,
    'retry_delay': timedelta(seconds=15),
}

# Criação da DAG
with DAG(
    dag_id='dag_teste_erro',
    default_args=default_args,
    description='DAG de teste',
    schedule_interval=timedelta(minutes=1),
    start_date=datetime(2024, 1, 1),
    catchup=False,
) as dag:

    # Tarefa Dummy para teste
    start = DummyOperator(
        task_id='start'
    )

    # Tarefa Python que imprime uma mensagem
    hello_task = PythonOperator(
        task_id='print_hello',
        python_callable=print_hello
    )

    # Tarefa Dummy de fim
    end = DummyOperator(
        task_id='end'
    )

    # Definindo a ordem das tarefas
    start >> hello_task >> end
