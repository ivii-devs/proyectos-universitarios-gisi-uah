#ifndef COLA_H
#define COLA_H

#include "NodoCola.h"
#include "Documento.h"
#include <iostream>

class Cola
{
    public:
        Cola();
        Cola(const Cola& otra);
        Cola& operator=(const Cola& otra);
        ~Cola();

        bool esVaciaCola();
        void encolar(Documento doc);
        void encolarPrioridad(Documento doc);
        int inicio();
        int fin();
        void desencolar();
        void mostrarCola();
        int getLongitud();
        void disminuirLongitud();
        Documento obtenerPrimero();

    protected:

    private:
        NodoCola *primero; //Puntero que apunta al primer nodo de la cola
        NodoCola *ultimo; //Puntero que apunta al ultimo nodo de la cola
        int longitud; //Para poder calcular la cantidad de elementos en la cola
};

#endif // COLA_H
