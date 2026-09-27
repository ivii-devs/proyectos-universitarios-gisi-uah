#include "Impresora.h"
#include <iostream>

using namespace std;

Impresora::Impresora()
{
    this->idImpresora = 0;
    this->ocupada = false;
    this->tiempoRestante = 0;
}

Impresora::Impresora(int idImpresora)
{
    this->idImpresora = idImpresora;
    this->ocupada = false;
    this->tiempoRestante = 0;
}

Impresora::~Impresora()
{
    //dtor
}

void Impresora::setTiempoRestanteReset() {
    tiempoRestante = 0;
}

void Impresora::setOcupadaReset() {
    ocupada = false;
}

//Asignar un documento a la impresora
void Impresora::asignarDocumento(Documento doc) {
    documentoActual = doc;
    tiempoRestante = doc.getTiempoImpresion();
    ocupada = true;
    cout << "Documento ID (" << doc.getIdDocumento() << ") asignado a la Impresora ID (" << getIdImpresora() << ") " << endl;
}

//Actualizar el estado (tiempo) de una impresora
bool Impresora::actualizar(int tiempo) {
    (void)tiempo; // Parametro reservado para simulacion por pasos
    if(ocupada) {
        tiempoRestante -= 1;
        if(tiempoRestante <= 0) {
            return true;
        }
    }
    return false;
}

//Liberar impresora
void Impresora::liberar() {
    ocupada = false;
    tiempoRestante = 0;
    cout << "El Documento ID (" << documentoActual.getIdDocumento() << ") ha terminado de imprimirse por la Impresora ID (" << idImpresora << ") " << endl;
    cout << endl;

    //Si hay documentos en la cola, asignamos el siguiente
    if (hayDocumentosEnCola()) {
        asignarDocumento(colaDocumentos.obtenerPrimero());
        colaDocumentos.desencolar();
        colaDocumentos.disminuirLongitud();
    }
}

//Comprobar si la impresora esta libre
bool Impresora::estaLibre() {
    return !ocupada;
}

//Mostrar el estado de la impresora
void Impresora::mostrarEstado() {
    if (ocupada) {
        cout << "/// IMPRESORA ID (" << idImpresora << ") ///" << endl;
        cout << "   Imprimiendo Documento ID: " << documentoActual.getIdDocumento() << endl;
        cout << "   Tiempo Restante: " << tiempoRestante << " minutos" << endl;
        cout << "   Cola de Espera: " << endl;
        mostrarColaDocumentos();
    } else {
        cout << "La Impresora (" << idImpresora << ") esta libre." << endl;
    }
}

//Obtener el id de la impresora
int Impresora::getIdImpresora() {
    return idImpresora;
}

//Obtener tiempo restante
int Impresora::getTiempoRestante() {
    return tiempoRestante;
}

//Obtener el documento actual
Documento Impresora::getDocumentoActual() {
    return documentoActual;
}

void Impresora::agregarDocumentoCola(Documento doc) {
    if (!ocupada) {
        asignarDocumento(doc);
    }
    else {
        colaDocumentos.encolarPrioridad(doc);
        cout << "Cola de documentos de la Impresora (" << idImpresora << "): " << endl;
        mostrarColaDocumentos();
        cout << endl;
        cout << "Longitud de la cola de documentos de la Impresora (" << idImpresora << "): "<< colaDocumentos.getLongitud() << endl;
        cout << endl;
        cout << "Documento ID (" << doc.getIdDocumento() << ") agregado a la cola de espera de la Impresora ID (" << idImpresora << ") " << endl;
        cout << endl;
    }
}

void Impresora::mostrarColaDocumentos() {
    colaDocumentos.mostrarCola();
}

bool Impresora::hayDocumentosEnCola() {
    return !colaDocumentos.esVaciaCola();
}

Cola& Impresora::getColaDocumentos() {
    return colaDocumentos;
}
