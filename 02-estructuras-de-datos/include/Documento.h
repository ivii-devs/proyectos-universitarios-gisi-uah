#ifndef DOCUMENTO_H
#define DOCUMENTO_H
#include <string.h>
#include <iostream>

using namespace std;

class Documento
{
    public:
        //Constructor vacio
        Documento();

        //Constructor sin idImpresora
        Documento(int idDocumento, int tiempoLlegada, int tiempoImpresion, string departamento, int prioridad);

        //Constructor con idImpresora
        Documento(int idDocumento, int tiempoLlegada, int tiempoImpresion, string departamento, int prioridad, int idImpresora);

        //Destructor
        virtual ~Documento();

        //Getters
        int getIdDocumento();
        int getTiempoLlegada();
        int getTiempoImpresion();
        string getDepartamento();
        int getIdImpresora();
        int getPrioridad();

        //Setter
        void setIdImpresora(int idImpresora);

        //Otros metodos
        void mostrarDatos();
        void mostrarDatosSimp();

    private:
        int idDocumento;
        int tiempoLlegada;
        int tiempoImpresion;
        string departamento;
        int idImpresora;
        int prioridad;

};

#endif // DOCUMENTO_H

