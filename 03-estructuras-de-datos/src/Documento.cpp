#include "Documento.h"
#include <string>
#include <iostream>

using namespace std;

Documento::Documento()
{
    this->idDocumento = 0;
    this->tiempoLlegada = 0;
    this->tiempoImpresion = 0;
    this->departamento = "";
    this->prioridad = 0;
    this->idImpresora = -1;
}

Documento::Documento(int idDocumento, int tiempoLlegada, int tiempoImpresion, string departamento, int prioridad)
{
    this->idDocumento = idDocumento;
    this->tiempoLlegada = tiempoLlegada;
    this->tiempoImpresion = tiempoImpresion;
    this->departamento = departamento;
    this->prioridad = prioridad;
    this->idImpresora = -1;
}

Documento::Documento(int idDocumento, int tiempoLlegada, int tiempoImpresion, string departamento, int prioridad, int idImpresora)
{
    this->idDocumento = idDocumento;
    this->tiempoLlegada = tiempoLlegada;
    this->tiempoImpresion = tiempoImpresion;
    this->departamento = departamento;
    this->prioridad = prioridad;
    this->idImpresora = idImpresora;
}

Documento::~Documento()
{
    //dtor
}

//Getters
int Documento::getIdDocumento() {
    return idDocumento;
}

int Documento::getTiempoLlegada() {
    return tiempoLlegada;
}

int Documento::getTiempoImpresion() {
    return tiempoImpresion;
}

string Documento::getDepartamento() {
    return departamento;
}

int Documento::getPrioridad() {
    return prioridad;
}

int Documento::getIdImpresora() {
    return idImpresora;
}

//Setters
void Documento::setIdImpresora(int idImpresora) {
    this->idImpresora = idImpresora;
}

void Documento::mostrarDatos() {
    cout << "/// ID DOCUMENTO (" << idDocumento << ") ///" << endl;
    cout << "Hora de llegada: " << tiempoLlegada << " minutos (desde las 07:00)" << endl;
    cout << "Tiempo de impresion: " << tiempoImpresion << " minutos" << endl;
    cout << "Departamento: " << departamento << endl;
    cout << "Prioridad: " << prioridad << endl;
    if (idImpresora != -1) {
        cout << "Impresora asignada: " << idImpresora << endl;
    } else {
        cout << "Impresora asignada: Sin asignar" << endl;
    }
    cout << endl;
}

void Documento::mostrarDatosSimp() {
    cout << "Documento ID (" << idDocumento << ") con Prioridad (" << prioridad << ") " << endl;
}
