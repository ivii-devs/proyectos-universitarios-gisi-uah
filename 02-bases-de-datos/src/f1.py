import psycopg2
import pandas as pd
import sys
from psycopg2 import sql
from datetime import datetime

# Diccionario con las consultas SQL
CONSULTAS_SQL = {
    '1': ("""
        SELECT c.nombre AS circuito, COUNT(*) AS numero_grandes_premios
        FROM ddbb.circuitos c
        JOIN ddbb.carreras gp ON c.circuito_ref = gp.circuito_ref
        GROUP BY c.circuito_ref, c.nombre
        ORDER BY numero_grandes_premios DESC;
    """),
    '2': ("""
        SELECT COUNT(co.piloto_ref) AS numero_grandes_premios, SUM(co.puntos) AS puntos_totales
        FROM ddbb.corre co
        JOIN ddbb.pilotos p ON co.piloto_ref = p.piloto_ref
        WHERE p.nombre = 'Ayrton' AND p.apellido = 'Senna';
    """),
    '3': ("""
        SELECT p.nombre, p.apellido, COUNT(*) AS numero_carreras
        FROM ddbb.pilotos p
        JOIN ddbb.corre co ON p.piloto_ref = co.piloto_ref
        WHERE p.fecha_nacimiento > '1999-12-31'
        GROUP BY p.piloto_ref, p.nombre, p.apellido
        ORDER BY numero_carreras DESC;
    """),
    '4': ("""
        SELECT e.nombre, e.nacionalidad, COUNT(*) AS numero_participaciones
        FROM ddbb.escuderias e
        JOIN ddbb.corre co ON e.escuderia_ref = co.escuderia_ref
        WHERE e.nacionalidad = 'Spanish' OR e.nacionalidad = 'Italian'
        GROUP BY e.escuderia_ref, e.nombre, e.nacionalidad
        ORDER BY numero_participaciones DESC;
    """),
    '5': ("""
        CREATE OR REPLACE VIEW ddbb.vista_puntos_por_temporada AS 
        SELECT co.anio_carrera AS temporada, p.nombre, p.apellido, SUM(co.puntos) AS puntos_totales_temporada 
        FROM ddbb.corre co 
        JOIN ddbb.pilotos p ON co.piloto_ref = p.piloto_ref 
        GROUP BY co.anio_carrera, p.piloto_ref, p.nombre, p.apellido 
        ORDER BY temporada DESC, puntos_totales_temporada DESC;
    """),
    '6': ("""
        SELECT DISTINCT ON (vp.temporada) vp.temporada, vp.nombre, vp.apellido, vp.puntos_totales_temporada
        FROM ddbb.vista_puntos_por_temporada vp
        WHERE vp.temporada BETWEEN 2010 AND 2015
        ORDER BY vp.temporada DESC, vp.puntos_totales_temporada DESC;
    """),
    '7': ("""
        SELECT DISTINCT p.nombre, p.apellido
        FROM ddbb.pilotos p
        JOIN ddbb.corre co ON p.piloto_ref = co.piloto_ref
        WHERE co.posicion = 1
        ORDER BY p.apellido, p.nombre;
    """),
    '8': ("""
        SELECT c.ciudad AS pais, COUNT(*) AS numero_grandes_premios
        FROM ddbb.circuitos c
        JOIN ddbb.carreras gp ON c.circuito_ref = gp.circuito_ref
        GROUP BY c.ciudad
        ORDER BY numero_grandes_premios DESC;
    """),
    '9': ("""
        SELECT p.nombre, p.apellido, v.tiempo AS vuelta_mas_rapida
        FROM ddbb.vueltas v
        JOIN ddbb.pilotos p ON v.piloto_ref = p.piloto_ref
        WHERE v.tiempo = (SELECT MIN(tiempo) FROM ddbb.vueltas WHERE tiempo > '00:00:00');
    """),
    '10': ("""
        SELECT p.nombre, p.apellido, COUNT(*) AS numero_paradas
        FROM ddbb.boxes b
        JOIN ddbb.corre co ON b.piloto_ref = co.piloto_ref AND b.nombre_carrera = co.nombre_carrera AND b.anio_carrera = co.anio_carrera AND b.circuito_ref_carrera = co.circuito_ref_carrera
        JOIN ddbb.carreras ca ON co.nombre_carrera = ca.nombre AND co.anio_carrera = ca.anio AND co.circuito_ref_carrera = ca.circuito_ref
        JOIN ddbb.pilotos p ON co.piloto_ref = p.piloto_ref
        WHERE ca.nombre = 'Monaco Grand Prix' AND ca.anio = 2023
        GROUP BY p.nombre, p.apellido
        ORDER BY numero_paradas DESC;
    """),
    '11': ("""
        SELECT p.nombre, p.apellido, COUNT(*) AS numero_grandes_premios
        FROM ddbb.corre co
        JOIN ddbb.pilotos p ON co.piloto_ref = p.piloto_ref
        GROUP BY p.piloto_ref, p.nombre, p.apellido
        HAVING COUNT(*) > 100
        ORDER BY numero_grandes_premios DESC;
    """)
}

# Funcion para conectar a la base de datos
def conectar_bd():
    # Mostramos la lista de usuarios y pedimos credenciales
    print("\n============================= CONEXIÓN A LA BASE DE DATOS =============================")
    print("Lista de usuarios disponibles:")
    print("------------------------------")
    print("1 - Administrador")
    print("2 - Gestor")
    print("3 - Analista")
    print("4 - Invitado")
    print("0 - Salir")

    # Pedimos al usuario que seleccione un rol
    rol = input("\nSeleccione una opción: ")

    # Mapeo de opciones a nombres de usuario
    # Usamos un diccionario para simplificar la selección
    roles_dict = {
        '1': 'administrador',
        '2': 'gestor',
        '3': 'analista',
        '4': 'invitado',
        '0': 'salir'
    }

    # Si la opción no es válida, pedimos de nuevo con un bucle
    while rol not in roles_dict:
        print("\nOpción no válida. Intente de nuevo.")
        rol = input("\nSeleccione una opción: ")

    # Si el usuario selecciona salir, terminamos el programa
    if rol == '0':
        print("\nSaliendo del programa.")
        sys.exit(0)

    # Obtenemos el nombre de usuario correspondiente
    usuario = roles_dict[rol]
    print(f"\nUsuario seleccionado: {usuario}")

    # Solicitamos la contraseña
    password = input("\nContraseña: ")

    # Intentamos conectar a la base de datos
    try:
        conn = psycopg2.connect(
            dbname="pruebas",
            user=usuario,
            password=password,
            host="localhost",
            port="5432",
            options="-c client_encoding=UTF8"
        )
        print("\n========================================")
        print(f"[ÉXITO] Conectado como '{usuario}'.")
        print("========================================")
        return conn, usuario # Devolvemos también el nombre del usuario para mostrarlo
    
    # Manejamos errores de conexión
    except psycopg2.OperationalError as e:
        print("\n[ERROR] Usuario o contraseña incorrectos. Intente de nuevo.\n")
        return conectar_bd()
    except UnicodeDecodeError as e:
        print(f"\n[ERROR] Problema de codificación: {e}")
        return conectar_bd()
    except psycopg2.Error as e:
        print(f"\n[ERROR] No se pudo conectar: {e}")
        return conectar_bd()

# Funcion para mostrar el menu de consultas
# Esta funcion llama a ejecutar_consulta con la consulta SQL seleccionada
def menu_consultas(conn):
    # Bucle principal del menú de consultas para selección de consultasç
    # De este modo, si se introduce una opción inválida, se vuelve a mostrar el menú
    while True:
        print("\n============================= MODO CONSULTA =============================\n")
        print("Consultas disponibles:")
        print("----------------------------------------------------------------------------")
        print("1. Listado de circuitos y numero de GPs")
        print("2. GPs corridos y puntos totales de Ayrton Senna")
        print("3. Pilotos nacidos a partir del 2000 y sus carreras")
        print("4. Escuderias espaniolas o italianas y sus grandes premios disputados")
        print("5. Vista de pilotos y puntos totales por temporada")
        print("6. Pilotos ganadores de las temporadas 2010-2015")
        print("7. Pilotos que han ganado al menos un Gran Premio")
        print("8. Numero de Grandes Premios por pais")
        print("9. Piloto con la vuelta mas rapida en la historia")
        print("10. Numero de paradas en boxes por piloto en el GP de Monaco 2023")
        print("11. Pilotos con mas de 100 grandes premios disputados")
        print("0. Salir")
        print("----------------------------------------------------------------------------")

        # Pedimos al usuario que seleccione una consulta
        opcion = input("Seleccione una consulta: ")

        if opcion == '0':
            print("Saliendo del programa.")
            break
        elif opcion in CONSULTAS_SQL:
            ejecutar_consulta(conn, CONSULTAS_SQL[opcion])
        else:   
            print("Opción no valida. Seleccione una consulta valida.")

# Funcion para ejecutar una consulta SQL
# Esta funcion recibe la conexion de la funcion conectar_bd y la consulta SQL de CONSULTAS_SQL seleccionada en menu_consultas
def ejecutar_consulta(conn, consulta_data):
    # Ejecuta la consulta SQL seleccionada por el usuario
    codigo_sql = consulta_data

    print(f"\n===== EJECUTANDO CONSULTA =====\n")
    
    # Ejecutamos con un TRY EXCEPT para manejar errores
    try:
        # ejecutamos la consulta con pandas para mejor visualizacion
        df = pd.read_sql_query(codigo_sql, conn)
        
        # sI no hay resultados, indicamos que no hay resultados
        if df.empty:
            print("[SIN RESULTADOS]")
        # Si hay resultados, los mostramos. Para mejor visualizacion usamos pandas
        else:
            print(df.to_string(index=False))

    except psycopg2.errors.InsufficientPrivilege:
        print("\n[ACCESO DENEGADO] No tienes permisos para ver estos datos (ej. boxes).")
        conn.rollback()
    except Exception as e:
        print(f"\n[ERROR SQL] {e}")
        conn.rollback()

'''
Ya que para insertar un nuevo gp se debe respetar la integridad referencial, hemos creado un flujo
que si el usuario intenta crear un GP con una temporada o circuito que no existe, estos se crean automaticamente
'''

# Para ello, definimos las siguientes funciones auxiliares para la comprobación
def existe_temporada(cursor, anio):
    cursor.execute("SELECT 1 FROM ddbb.temporadas WHERE anio = %s", (anio,))
    return cursor.fetchone() is not None

def existe_circuito(cursor, circuito_ref):
    cursor.execute("SELECT 1 FROM ddbb.circuitos WHERE circuito_ref = %s", (circuito_ref,))
    return cursor.fetchone() is not None

def existe_piloto(cursor, piloto_ref):
    cursor.execute("SELECT 1 FROM ddbb.pilotos WHERE piloto_ref = %s", (piloto_ref,))
    return cursor.fetchone() is not None

def existe_escuderia(cursor, escuderia_ref):
    cursor.execute("SELECT 1 FROM ddbb.escuderias WHERE escuderia_ref = %s", (escuderia_ref,))
    return cursor.fetchone() is not None

def existe_carrera(cursor, anio, circuito, nombre):
    cursor.execute("""
        SELECT 1 FROM ddbb.carreras WHERE anio = %s AND circuito_ref = %s AND nombre = %s""", (anio, circuito, nombre))
    return cursor.fetchone() is not None

'''
Las siguientes funciones son auxiliares para hacer la inserción y comprobación de datos automaticamente (opciones 1 y 2)
'''

def insertar_gp(conn):
    cursor = conn.cursor()

    try:    
        print("\n[Nuevo Gran Premio]")
        anio = input("Año (YYYY): ")
        circuito = input("Ref. Circuito: ")
        nombre = input("Nombre GP: ")
        ronda = input("Ronda: ")
        url = input("URL: ")

        # Pedimos fecha y hora
        fecha_input = input("Fecha y Hora (AAAA-MM-DD HH:MM): ")

        # Lo convertimos a datetime
        fecha_hora = datetime.strptime(fecha_input, "%Y-%m-%d %H:%M")

        # Verificar si el Gran Premio ya existe
        cursor.execute(
            "SELECT 1 FROM ddbb.carreras WHERE anio = %s AND circuito_ref = %s AND nombre = %s",
            (anio, circuito, nombre)
        )
        if cursor.fetchone():
            print("\n[AVISO] Este Gran Premio ya existe en la base de datos.")
            return

        # Primero verificamos que exista la temporada
        if not existe_temporada(cursor, anio):
            print(f"\n[AVISO] La temporada {anio} NO existe.")

            # Si no existe preguntamos:
            crear_sn = input("¿Desea crear la Temporada? (s/n): ")

            if crear_sn == 's':
                url = input("Introduzca la URL de la Temporada: ")

                # Insertamos la temporada
                cursor.execute("INSERT INTO ddbb.temporadas (anio, url) VALUES (%s, %s)", (anio, url))
                print(f"// Temporada {anio} creada correctamente //")

                # Verificamos que la temporada se haya insertado
                cursor.execute("SELECT * FROM ddbb.temporadas WHERE anio = %s", (anio,))
                temporada_insertada = cursor.fetchone()
                if temporada_insertada:
                    print(f"[VERIFICACIÓN] Temporada insertada: {temporada_insertada}")
                else:
                    print("[ERROR] No se pudo verificar la inserción de la temporada.")
            else:
                print("\nOperación cancelada...")
                conn.rollback()
                return
            
        # Verificamos si el circuito existe
        if not existe_circuito(cursor, circuito):
            print(f"\n[AVISO] El circuito '{circuito}' NO existe.")

            crear = input("¿Desea crearlo automáticamente? (s/n): ")
            if crear == 's':
                nombre = input("Introduzca el NOMBRE del Circuito: ")
                localizacion = input("Introduzca el PAIS del Circuito: ")
                ciudad = input("Introduzca la CIUDAD del Circuito: ")
                latitud = input("Introduzca la LATITUD el Circuito")
                longitud = input("Introduzca la LONGITUD del Circuito: ")
                altura = input("Introduzca la ALTURA del Circuito: ")
                url = input("Introduzca la URL del Circuito: ")

                # Creamos un circuito con los datos mínimos
                sql = """INSERT INTO ddbb.circuitos (circuito_ref, nombre, localizacion, ciudad, latitud, longitud, altura, url)
                            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)"""

                # Lo insertamos
                cursor.execute(sql, (circuito, nombre, localizacion, ciudad, latitud, longitud, altura, url))
                print(f"// Circuito {circuito} creado correctamente //")

                # Verificamos que el circuito se haya insertado
                cursor.execute("SELECT * FROM ddbb.circuitos WHERE circuito_ref = %s", (circuito,))
                circuito_insertado = cursor.fetchone()
                if circuito_insertado:
                    print(f"[VERIFICACIÓN] Circuito insertado: {circuito_insertado}")
                else:
                    print("[ERROR] No se pudo verificar la inserción del circuito.")
            else: 
                print("Operación cancelada.")
                conn.rollback()
                return
            
        # Ahora si, insertamos el GP
        sql = """
            INSERT INTO ddbb.carreras (anio, circuito_ref, nombre, ronda, fecha_hora, url) 
            VALUES (%s, %s, %s, %s, %s, %s);
        """

        cursor.execute(sql, (anio, circuito, nombre, ronda, fecha_hora, url))
        conn.commit()

        print("\n[ÉXITO] Gran Premio insertado correctamente:")
        print(f" - Nombre: {nombre}")
        print(f" - Año: {anio}")
        print(f" - Circuito: {circuito}")
        print("// Gran Premio insertado correctamente //")

        cursor.execute(
            "SELECT 1 FROM ddbb.carreras WHERE anio = %s AND circuito_ref = %s AND nombre = %s",
            (anio, circuito, nombre)
        )
    
    except psycopg2.errors.InsufficientPrivilege:
        print("\n[ACCESO DENEGADO] Tu usuario no tiene permisos de escritura.")
        conn.rollback()
    except psycopg2.errors.UniqueViolation:
        print("\n[ERROR] Este Gran Premio ya existe.")
        print("No se pueden insertar duplicados.")
        conn.rollback()
    except Exception as e:
        print(f"\n[ERROR] {e}")
        conn.rollback() 

def insertar_nuevo_resultado(conn):
    cursor = conn.cursor()

    try:
        print("\n[Nuevo Resultado]")
        piloto = input("Ref. Piloto: ")
        escuderia = input("Ref. Escudería: ")
        # Datos de la carrera para identificarla o crearla
        nombre_gp = input("Nombre GP: ")
        anio = input("Anio GP: ")
        circuito = input("Ref. Circuito: ")
        
        puntos = input("Puntos: ")
        posicion = input("Posicion: ")
        estado = input("Estado: ")

        #Verificamos si existe el nuevo resultado en la tabla corre
        cursor.execute(
            "SELECT 1 FROM ddbb.corre WHERE piloto_ref = %s AND anio_carrera = %s AND circuito_ref_carrera = %s AND escuderia_ref = %s", 
            (piloto, anio, circuito, escuderia)
        )

        if cursor.fetchone():
            print("\n[AVISO] Este resultado ya existe en la base de datos.")
            return

        # 1. Verificamos si exixte el piloto
        if not existe_piloto(cursor, piloto):
            print(f"\n[AVISO] El piloto {piloto} NO existe.")

            # Si no existe preguntamos:
            piloto_sn = input("[¿Desea crear el Piloto automaticamente? (s/n): ")
            
            if piloto_sn == 's':
                # Insertamos un piloto
                numero = input("Introduzca el NUMERO del Piloto: ")
                codigo = input("Introduzca el CODIGO del Piloto: ")
                nombre = input("Introduzca el NOMBRE del Piloto: ")
                apellido = input("Introduzca el APELLIDO del Piloto: ")
                nacionalidad = input("Introduzca la NACIONALIDAD del Piloto: ")
                url = input("Introduzca la URL del Piloto: ")

                fecha_input = input("Introduzca la FECHA DE NACIMIENTO del Piloto (AAAA-MM-DD): ")
                fecha_nac = datetime.strptime(fecha_input, "%Y-%m-%d")

                cursor.execute("""
                    INSERT INTO ddbb.pilotos (piloto_ref, numero, codigo, nombre, apellido, fecha_nacimiento, nacionalidad, url) 
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """, (piloto, numero, codigo, nombre, apellido, fecha_nac, nacionalidad, url))

                print(f"// Piloto '{piloto}' creado //")

                # Verificamos que el piloto se haya insertado
                cursor.execute("SELECT * FROM ddbb.pilotos WHERE piloto_ref = %s", (piloto,))
                piloto_insertado = cursor.fetchone()
                if piloto_insertado:
                    print(f"[VERIFICACIÓN] Piloto insertado: {piloto_insertado}")
                else:
                    print("[ERROR] No se pudo verificar la inserción de el piloto.")
            else:
                print("\nOperación cancelada...")
                conn.rollback()
                return

        # 2. Verificamos si existe la escuderia
        if not existe_escuderia(cursor, escuderia):
            print(f"\n[AVISO] La escuderia {escuderia} NO existe.")

            # Si no existe preguntamos:
            escuderia_sn = input("[¿Desea crear la Escuderia automaticamente? (s/n): ")

            if escuderia_sn == 's':
                nombre = input("Introduzca el NOMBRE de la Escuderia: ")
                nacionalidad = input("Introduzca la NACIONALIDAD de la Escuderia: ")
                url = input("Introduzca la URL de la Escuderia: ")


                cursor.execute("""
                    INSERT INTO ddbb.escuderias (escuderia_ref, nombre, nacionalidad, url) 
                    VALUES (%s, %s, %s, %s)
                """, (escuderia, nombre, nacionalidad, url))
                print(f"// Escudería '{escuderia}' creada //")

                # Verificamos que la escuderia se haya insertado
                cursor.execute("SELECT * FROM ddbb.escuderias WHERE escuderia_ref = %s", (escuderia,))
                escuderia_insertada = cursor.fetchone()
                if escuderia_insertada:
                    print(f"[VERIFICACIÓN] Escuderia insertada: {escuderia_insertada}")
                else:
                    print("[ERROR] No se pudo verificar la inserción de la escuderia.")
            else:
                print("\nOperación cancelada...")
                conn.rollback()
                return
            
        # 3. Verificamos si existe la carrera (Dependencias: Temporada, Circuito -> Carrera)
        if not existe_carrera(cursor, anio, circuito, nombre_gp):
            print(f"\n[AVISO] La carrera '{nombre_gp}' en el año {anio} y circuito '{circuito}' NO existe.")

            carrera_sn = input("[¿Desea crear el Gran Premio automaticamente? (s/n): ")
            
            if carrera_sn == 's':
                insertar_gp(conn)
            else:
                print("Operación cancelada.")
                conn.rollback()
                return

        # 4. Insertar RESULTADO
            sql = """
                INSERT INTO ddbb.corre (piloto_ref, nombre_carrera, anio_carrera, circuito_ref_carrera, escuderia_ref, posicion, puntos, estado) 
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                RETURNING piloto_ref, puntos;
            """
            cursor.execute(sql, (piloto, nombre_gp, anio, circuito, escuderia, posicion, puntos, estado))
            conn.commit()
            
            print(f"\n[EXITO] Resultado insertado correctamente:")
            print(f" - Piloto: {piloto}")
            print(f" - Gran Premio: {nombre_gp}")
            print(f" - Anio: {anio}")
            print(f" - Circuito: {circuito}")
            print(f" - Escuderia: {escuderia}")
            print(f" - Posicion: {posicion}")
            print(f" - Puntos: {puntos}")
            print(f" - Estado: {estado}")

            cursor.execute(
            "SELECT 1 FROM ddbb.corre WHERE piloto_ref = %s AND anio_carrera = %s AND circuito_ref_carrera = %s AND escuderia_ref = %s", 
            (piloto, anio, circuito, escuderia)
        )

    except psycopg2.errors.InsufficientPrivilege:
        print("\n[ACCESO DENEGADO] Tu usuario no tiene permisos de escritura.")
        conn.rollback()
    except psycopg2.errors.UniqueViolation:
        print("\n[ERROR] Este Resultado ya existe.")
        print("No se pueden insertar duplicados.")
        conn.rollback()
    except Exception as e:
        print(f"\n[ERROR] {e}")
        conn.rollback()

# Funcion para insertar datos (modo escritura)
def insertar_datos(conn):
    print("\n ============================= MODO ESCRITURA =============================\n")
    print("1. [AUTO] Insertar Nuevo Gran Premio (Carrera)")
    print("2. [AUTO] Insertar Resultado de Carrera")
    print("0. Salir")

    opcion = input("Seleccione una opción: ")
    cursor = conn.cursor()

    try:
        if opcion == '1':
            insertar_gp(conn)
            
        elif opcion == '2':
            insertar_nuevo_resultado(conn)
            
    except psycopg2.errors.InsufficientPrivilege:
        print("\n[ACCESO DENEGADO] Tu usuario no tiene permisos de escritura.")
        conn.rollback()
    except psycopg2.errors.UniqueViolation:
        print("\n[ERROR] Este Gran Premio o Resultado ya existe.")
        print("No se pueden insertar duplicados.")
        conn.rollback()
    except Exception as e:
        print(f"\n[ERROR] {e}")
        conn.rollback()

# Funcion principal que maneja el flujo del programa y muestra el menu principal
def main():
    # Conectamos a la base de datos
    conn, usuario = conectar_bd()

    # Mostramos el menú principal
    while True:
        print(f"\n===== MENÚ PRINCIPAL ({usuario}) =====")
        print("1. Ejecutar Consultas")
        print("2. Insertar Datos (Gestor/Admin)")
        print("0. Salir")

        opt = input("Seleccione una opción: ")

        if opt == '1':
            menu_consultas(conn)
        elif opt == '2':
            insertar_datos(conn)
        elif opt == '0':
            print("Saliendo del programa.")
            break
        else:
            print("Opcion no valida. Intente de nuevo.")
    # Cerramos la conexión al salir
    conn.close()

if __name__ == "__main__":
    main()