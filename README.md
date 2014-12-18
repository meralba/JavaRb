JavaRb (V 1.0)
======

Tool that translates Java's files to Ruby's files.
This's the first version. Only translate the nexts funtionalities:
  1. Package statement.
  2. Class statement.
  3. Attributes class.
  4. Methods with or without return.
  5. Equality operator and simple instructions.
  6. Call methods.
  7. toString method.
  8. Builders.
  9. Prints.
  10. Increments and decrements.
  11. Main method.
  12. Scan keyboard.
  13. Comments on one or more lines.
  14. Simple if/else

How to make it work?
This is code in C and Lex.
  1. lex prog.l
  2. gcc lex.yy.c -o prog -ll
  3. ./prog example.java
  4. example.rb has been created.

======
Herramienta que traduce archivos en Java a archivos en Ruby.

En esta primera versión, tiene algunas limitaciones. Por ahora solo traduce las siguientes funcionalidades:
  1. Declaración de "package".
  2. Declaración de clases.
  3. Atributos de las clases.
  4. Métodos con o sin valor devuelto.
  5. Igualdades e instrucciones sencillas.
  6. Llamada a métodos.
  7. Método "toString" de clases.
  8. Constructores.
  9. Imprimir en pantalla.
  10. Incrementos y decrementos.
  11. Método main.
  12. Recibir datos de teclado.
  13. Comentarios en una y varias líneas
  14. if/else simples.

Se pretende aumentar en las proxímas versiones a las siguientes funcionalidades (si es posible):
  1. Reconocer getters y setter.
  2. Operaciones del tipo "+="
  3. Bucles.
  4. Interfaces,implements y demás.
  5. Clases definidas en Java tipo Random y sus métodos correspondientes.

¿Cómo hacer que funcione?
  Es código en C y en Lex.
  1. lex prog.l
  2. gcc lex.yy.c -o prog -ll
  3. ./prog example.java
  4. example.rb debe haber sido creado.
