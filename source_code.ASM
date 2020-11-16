; PROYECTO 2 ENSAMBLADOR 2048.
; AUTORES:
; JESÚS ALONSO MORENO MONTERO — B95346

format PE GUI 4.0
entry start

include 'C:\Ensambla_TP2\win32a.inc'

cdXPos           EQU  300
cdYPos           EQU  50
windowWidth      EQU  720     ; Constante double X-tamaño de la ventana
windowHeight     EQU  770     ; Constante double Y-tamaño de la ventana

cdColFondo       EQU  COLOR_BTNFACE + 1
cdVIcono         EQU  IDI_APPLICATION
cdVCursor        EQU  IDC_ARROW

cdVBarTipo       EQU  NULL
cdVBtnTipo       EQU  WS_GROUP+WS_SYSMENU+WS_VISIBLE
cdID_OBJETO      EQU  500

FLOODFILLSURFACE equ  1

cdimagen_0    EQU  200
cdimagen_2    EQU  201
cdimagen_4    EQU  202
cdimagen_8    EQU  203
cdimagen_16     EQU  204
cdimagen_32     EQU  205
cdimagen_64     EQU  206
cdimagen_128    EQU  207
cdimagen_256    EQU  208
cdimagen_512    EQU  209
cdimagen_1024   EQU  210
cdimagen_2048   EQU  211


cdIDC_BUTTON     EQU  3000
cdIDC_UDC1       equ  1003
cdIDC_EDT1       equ  1002
cdIDC_STC7       equ  1008
cdIDC_STC8       equ  1009

; Otros
GMEM_FIXED       EQU  0h
GMEM_ZEROINIT    EQU  40h
GPTR             EQU  GMEM_FIXED + GMEM_ZEROINIT
TME_LEAVE        EQU  2
COLOR_3DFACE     EQU  COLOR_BTNFACE
HOVER_DEFAULT    EQU  0FFFFFFFFh
ID_STATIC        EQU  -1

struc DatosControl   dcClase,dcTexto,dcEstilo,dcPosX,dcPosY,dcAncho,dcAlto,objectPointer,dcHandle
{
  .dcClase     DD  dcClase
  .dcTexto     DD  dcTexto   
  .dcEstilo    DD  dcEstilo  
  .dcPosX      DD  dcPosX    
  .dcPosY      DD  dcPosY    
  .dcAncho     DD  dcAncho   
  .dcAlto      DD  dcAlto    
  .objectPointer  DD  objectPointer
  .dcHandle    DD  dcHandle  
}

DatosControl_size  EQU  9*4

struct TRACKMOUSEEVENT
  cbSize       dd ?
  dwFlags      dd ?
  hwndTrack    dd ?
  dwHoverTime  dd ?
ends

TRACKMOUSEEVENT_size equ 4*4
WNDCLASSEX_size      equ 4*12

section '.text' code readable executable
  start:
    invoke    GetModuleHandle,0
    mov       [wc.hInstance],eax
    invoke    GetCommandLine
    mov       [CommandLine], EAX
    stdcall   WinMain, [wc.hInstance], NULL, [CommandLine], SW_SHOWDEFAULT
    invoke    ExitProcess,[msg.wParam]

proc WinMain uses ebx esi edi, hInst, hPrevInst, CmdLine, CmdShow

    invoke    RegisterClass,wc
    test      eax,eax
    jz        error

    invoke    CreateWindowEx,cdVBarTipo,NombreClase,TituloVentana,\
              cdVBtnTipo,cdXPos, cdYPos, windowWidth, windowHeight,\
              NULL,NULL,[wc.hInstance],NULL
    test      eax,eax
    jz        error

    msg_loop:
      invoke    GetMessage,msg,NULL,0,0
      cmp       eax,1
      jb        end_loop
      jne       msg_loop
      invoke    TranslateMessage,msg
      invoke    DispatchMessage,msg
    jmp       msg_loop

  error:
    invoke    MessageBox,NULL,MsgError,NULL,MB_ICONERROR+MB_OK

  end_loop:
    MOV       EAX, [msg.wParam]
    ret
endp

proc WndProc uses ebx esi edi, hwnd,wmsg,wparam,lparam

    mov       eax, [wmsg]
    cmp       eax, WM_DESTROY
    jz        wmDestroy
    cmp       eax, WM_COMMAND
    jz        wmCommand
    cmp       eax, WM_CREATE
    jz        wmCreate

    wmDefault:
      invoke   DefWindowProcA, [hwnd], [wmsg], [wparam], [lparam]
      
      jmp      wmFin
    wmCreate:
      mov      eax, [hwnd]
      mov      [wHandle], eax
      stdcall  CreaObjetos, [hwnd]
      jmp      wmFin
    wmCommand:
      mov      eax, [wparam]
      cmp      eax, [btn_start.objectPointer]
      je       .btn_start
      cmp      eax, [btn_up.objectPointer]      
      je       .btn_up
      cmp      eax, [btn_left.objectPointer]
      je       .btn_left
      cmp      eax, [btn_right.objectPointer]
      je       .btn_right
      cmp      eax, [btn_down.objectPointer]
      je       .btn_down
      jmp      wmDefault
      
      .btn_start:      
      
        stdcall     ClearBoard     
        ; TEST BOARD.
;        mov     [matrix_game+0*4], 1
;        mov     [matrix_game+12*4], 1        
;        mov     [matrix_game+2*4], 5
;        mov     [matrix_game+3*4], 4
;        mov     [matrix_game+4*4], 10
;        mov     [matrix_game+5*4], 6
;        mov     [matrix_game+6*4], 2
;        mov     [matrix_game+7*4], 2
;        mov     [matrix_game+8*4], 4
;        mov     [matrix_game+9*4], 5
;        mov     [matrix_game+10*4], 3
;        mov     [matrix_game+11*4], 8
        ;
        
        mov         [bool_validmove], 1 
        stdcall     PlaceRandom
        stdcall     PlaceRandom                
        stdcall     DrawBoard
        jmp         wmDefault
      
      .btn_up:
        push    ecx edx eax
        mov     [bool_validmove], 0
        stdcall ClearChecks
        mov     ecx, 4
        .while_up:
            xor     edx, edx                        ; clear a edx.
            xor     eax, eax                        ; clear a eax.
            mov     edx, [matrix_game+ecx*4]        ; movemos el valor de la celda a edx.
            
            push    ecx
            
            cmp     edx, 0                      
            je      .is_zero_skip                        ; si es cero, skip.
            ; -- Revisar lo que este arriba            
            
            .check_up:
            mov     eax, [matrix_game+(ecx-4)*4]    ; movemos lo que esta arriba a eax.        
            cmp     eax, 0
            je      .skip_collision                 ; si NO es cero, quiere decir que hay algo entonces skip.            
            cmp     edx, eax
            jne     .skip_up
            cmp     [vector_checks+(ecx-4)*4], 1
            je      .is_zero_skip            
            inc     edx
            mov     [vector_checks+(ecx-4)*4], 1
            .skip_collision:
            ;cmp     eax, edx
            mov     [matrix_game+ecx*4], 0          ; movemos a la celda un 0.
            mov     [matrix_game+(ecx-4)*4], edx    ; movemos a la celda de arriba el valor que estaba abajo.
            mov     [bool_validmove], 1
            sub     ecx, 4
            cmp     ecx, 3
            jg      .check_up
            jmp     .is_zero_skip
            ; -- 
            .skip_up:
            pop     ecx
            mov     [vector_checks+(ecx-4)*4], 1
            jmp     .skip_pop
            .is_zero_skip:
            pop     ecx
            .skip_pop:                
            inc     ecx
            cmp     ecx, 16
            je      .while_up_end
            jmp     .while_up
        .while_up_end:
        pop     eax edx ecx     
        
        stdcall     PlaceRandom
        stdcall     DrawBoard
        stdcall     CheckWin
        stdcall     CheckLose
        jmp     wmDefault
        
      .btn_left:
      
        push       ecx edx eax
        mov         [bool_validmove], 0
        stdcall     ClearChecks     
        mov         ecx, 1
        .while_left:
            xor     edx, edx
            xor     eax, eax
            mov     edx, [matrix_game+ecx*4]
            
            push    ecx
            
            cmp     edx, 0
            je      .is_zero_skip_left
            
            .check_left:
            mov     eax, [matrix_game+(ecx-1)*4]
            cmp     eax, 0
            je      .skip_collision_left
            cmp     edx, eax
            jne     .skip_left
            cmp     [vector_checks+(ecx-1)*4], 1
            je      .skip_left     
            inc     edx
            mov     [vector_checks+(ecx-1)*4], 1
            .skip_collision_left:
            mov     [matrix_game+ecx*4], dword 0
            mov     [matrix_game+(ecx-1)*4], dword edx
            mov     [bool_validmove], 1
            dec     ecx
            cmp     ecx, 0
            je      .is_zero_skip_left
            cmp     ecx, 4
            je      .is_zero_skip_left
            cmp     ecx, 8
            je      .is_zero_skip_left
            cmp     ecx, 12
            je      .is_zero_skip_left
            jmp     .check_left
            
            .skip_left:
            mov [vector_checks+(ecx-1)*4], 1                        
            .is_zero_skip_left:
                pop     ecx
                .add_one:
                inc     ecx
                cmp     ecx, 4
                je      .add_one
                cmp     ecx, 8
                je      .add_one
                cmp     ecx, 12
                je      .add_one
                cmp     ecx, 16
                je      .while_left_end
                jmp     .while_left
        .while_left_end:
        pop     eax edx ecx
      
        stdcall     PlaceRandom
        stdcall     DrawBoard
        stdcall     CheckWin
        stdcall     CheckLose              
        jmp     wmDefault
        
      .btn_right:        
        
        push    ecx edx eax
        mov     [bool_validmove], 0
        stdcall ClearChecks
        mov     ecx, 14
        .while_right:
            xor     edx, edx
            xor     eax, eax
            mov     edx, [matrix_game+ecx*4]
            
            push    ecx
            
            cmp     edx, 0
            je      .is_zero_skip_right
            
            .check_right:
            mov     eax, [matrix_game+(ecx+1)*4]
            cmp     eax, 0
            je      .skip_collision_right
            cmp     edx, eax
            jne     .skip_right
            cmp     [vector_checks+(ecx+1)*4], 1
            je      .skip_right
            inc     edx
            mov     [vector_checks+(ecx+1)*4], 1
            
            .skip_collision_right:
            mov     [matrix_game+ecx*4], dword 0
            mov     [matrix_game+(ecx+1)*4], dword edx
            mov     [bool_validmove], 1
            inc     ecx
            cmp     ecx, 3
            je      .is_zero_skip_right
            cmp     ecx, 7
            je      .is_zero_skip_right
            cmp     ecx, 11
            je      .is_zero_skip_right
            cmp     ecx, 15
            je      .is_zero_skip_right
            jmp     .check_right
                       
            .skip_right:
            mov     [vector_checks+(ecx+1)*4], 1
            .is_zero_skip_right:
            pop     ecx
            .sub_one:
            sub     ecx, 1
            jc      .while_right_end
            cmp     ecx, 11
            je      .sub_one
            cmp     ecx, 7
            je      .sub_one
            cmp     ecx, 3
            je      .sub_one            
            jmp     .while_right
        
        .while_right_end:
        pop     eax edx ecx         
        
        stdcall     PlaceRandom
        stdcall     DrawBoard
        stdcall     CheckWin
        stdcall     CheckLose
        jmp     wmDefault
        
      .btn_down:
        push    ecx edx eax
        mov     [bool_validmove], 0
        stdcall ClearChecks
        mov     ecx, 11        
        .while_down:
            xor     edx, edx
            xor     eax, eax
            mov     edx, [matrix_game+ecx*4]
            
            push    ecx
            
            cmp     edx, 0
            je      .is_zero_skip_down
            
            .check_down:
            mov     eax, [matrix_game+(ecx+4)*4]
            cmp     eax, 0
            je      .skip_collision_down
            cmp     edx, eax
            jne     .skip_down
            cmp     [vector_checks+(ecx+4)*4], 1
            je      .skip_down
            inc     edx
            mov     [vector_checks+(ecx+4)*4], 1
            .skip_collision_down:
            mov     [matrix_game+ecx*4], dword 0
            mov     [matrix_game+(ecx+4)*4], dword edx
            mov     [bool_validmove], 1
            add     ecx, 4
            cmp     ecx, 11
            jg      .is_zero_skip_down
            jmp     .check_down                     
            
            .skip_down:
            mov     [vector_checks+(ecx+4)*4], 1            
            .is_zero_skip_down:
                pop     ecx
                sub     ecx, 1
                jc      .while_down_end
                jmp     .while_down
                
        .while_down_end: 
        pop     eax edx ecx
        
        stdcall     PlaceRandom
        stdcall     DrawBoard
        stdcall     CheckWin
        stdcall     CheckLose
        jmp     wmDefault
    wmDestroy:
      invoke   PostQuitMessage,0
    wmFin:
    ret
endp

proc  CreaObjetos uses ecx esi, uWnd
  mov       esi, 0
  mov       ecx, 1           ; Contador de objetos
  L_Crea_Objetos_Agrupadores:
    push      ecx
    push      esi
    invoke    CreateWindowEx, NULL,\
              ClaseBoton,\
              [esi+gpbBmp.dcTexto],\
              [esi+gpbBmp.dcEstilo],\
              [esi+gpbBmp.dcPosX],\
              [esi+gpbBmp.dcPosY],\
              [esi+gpbBmp.dcAncho],\
              [esi+gpbBmp.dcAlto],\
              [uWnd],[esi+gpbBmp.objectPointer], [wc.hInstance], 0
    mov       [esi+gpbBmp.dcHandle], eax      ; Guardamos su manejador
    pop       esi
    pop       ecx
    add       esi, DatosControl_size
  loop     L_Crea_Objetos_Agrupadores
  ; Creamos los botones del agrupador bmp
  mov      esi, 0             ; Puntero donde empieza a mirar
  mov      ecx, 16            ; Contador de objetos
  L_Crea_Objetos_But_BMP:
    push     ecx
    push     esi
    invoke   CreateWindowExA, NULL,\
             ClaseBoton,\
             [esi+btn_0_0.dcTexto],\
             [esi+btn_0_0.dcEstilo],\
             [esi+btn_0_0.dcPosX],\
             [esi+btn_0_0.dcPosY],\
             [esi+btn_0_0.dcAncho],\
             [esi+btn_0_0.dcAlto],\
             [gpbBmp.dcHandle], [esi+btn_0_0.objectPointer], [wc.hInstance], NULL
    mov      [esi+btn_0_0.dcHandle], eax      ; Guardamos su manejador
    pop      esi
    pop      ecx
    add      esi, DatosControl_size
  loop     L_Crea_Objetos_But_BMP

  invoke    CreateWindowExA, NULL,\
                 ClaseBoton,\
                 [btn_up.dcTexto],\
                 [btn_up.dcEstilo],\
                 [btn_up.dcPosX],\
                 [btn_up.dcPosY],\
                 [btn_up.dcAncho],\
                 [btn_up.dcAlto],\
                 [uWnd],[btn_up.objectPointer], [wc.hInstance], NULL
  mov       [btn_up.dcHandle], eax          ; Guardamos su manejador  
  
  invoke    CreateWindowExA, NULL,\
    ClaseBoton,\
    [btn_left.dcTexto],\
    [btn_left.dcEstilo],\
    [btn_left.dcPosX],\
    [btn_left.dcPosY],\
    [btn_left.dcAncho],\
    [btn_left.dcAlto],\
    [uWnd],[btn_left.objectPointer], [wc.hInstance], NULL
  mov       [btn_left.dcHandle], eax          ; Guardamos su manejador
  
  invoke    CreateWindowExA, NULL,\
    ClaseBoton,\
    [btn_right.dcTexto],\
    [btn_right.dcEstilo],\
    [btn_right.dcPosX],\
    [btn_right.dcPosY],\
    [btn_right.dcAncho],\
    [btn_right.dcAlto],\
    [uWnd],[btn_right.objectPointer], [wc.hInstance], NULL
  mov       [btn_right.dcHandle], eax          ; Guardamos su manejador
  
  invoke    CreateWindowExA, NULL,\
    ClaseBoton,\
    [btn_down.dcTexto],\
    [btn_down.dcEstilo],\
    [btn_down.dcPosX],\
    [btn_down.dcPosY],\
    [btn_down.dcAncho],\
    [btn_down.dcAlto],\
    [uWnd],[btn_down.objectPointer], [wc.hInstance], NULL
  mov       [btn_down.dcHandle], eax          ; Guardamos su manejador
  
 invoke    CreateWindowExA, NULL,\
    ClaseBoton,\
    [btn_start.dcTexto],\
    [btn_start.dcEstilo],\
    [btn_start.dcPosX],\
    [btn_start.dcPosY],\
    [btn_start.dcAncho],\
    [btn_start.dcAlto],\
    [uWnd],[btn_start.objectPointer], [wc.hInstance], NULL
  mov       [btn_start.dcHandle], eax          ; Guardamos su manejador
  

  invoke   LoadBitmap, [wc.hInstance], cdimagen_0
  mov      [bmp_imagen_0], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_2
  mov      [bmp_imagen_2], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_4
  mov      [bmp_imagen_4], eax  
  invoke   LoadBitmap, [wc.hInstance], cdimagen_8
  mov      [bmp_imagen_8], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_16
  mov      [bmp_imagen_16], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_32
  mov      [bmp_imagen_32], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_64
  mov      [bmp_imagen_64], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_128
  mov      [bmp_imagen_128], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_256
  mov      [bmp_imagen_256], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_512
  mov      [bmp_imagen_512], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_1024
  mov      [bmp_imagen_1024], eax
  invoke   LoadBitmap, [wc.hInstance], cdimagen_2048
  mov      [bmp_imagen_2048], eax
  
  
  
  push  edx
  mov   edx, [btn_0_0.dcHandle]  
  mov   [vector_buttons+0], edx
  mov   edx, [btn_0_1.dcHandle]  
  mov   [vector_buttons+4], edx
  mov   edx, [btn_0_2.dcHandle]  
  mov   [vector_buttons+8], edx
  mov   edx, [btn_0_3.dcHandle]  
  mov   [vector_buttons+12], edx
  mov   edx, [btn_1_0.dcHandle]
  mov   [vector_buttons+16], edx  
  mov   edx, [btn_1_1.dcHandle]  
  mov   [vector_buttons+20], edx
  mov   edx, [btn_1_2.dcHandle]  
  mov   [vector_buttons+24], edx
  mov   edx, [btn_1_3.dcHandle]  
  mov   [vector_buttons+28], edx
  mov   edx, [btn_2_0.dcHandle]  
  mov   [vector_buttons+32], edx
  mov   edx, [btn_2_1.dcHandle]  
  mov   [vector_buttons+36], edx
  mov   edx, [btn_2_2.dcHandle]  
  mov   [vector_buttons+40], edx
  mov   edx, [btn_2_3.dcHandle]
  mov   [vector_buttons+44], edx  
  mov   edx, [btn_3_0.dcHandle]  
  mov   [vector_buttons+48], edx
  mov   edx, [btn_3_1.dcHandle]  
  mov   [vector_buttons+52], edx
  mov   edx, [btn_3_2.dcHandle]  
  mov   [vector_buttons+56], edx
  mov   edx, [btn_3_3.dcHandle]  
  mov   [vector_buttons+60], edx
  pop   edx
  
  ; cargar el vector de imagenes
    
  push  edx
  mov   ecx, dword 0              ; 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
  .loadImageMatrix:
      xor     edx, edx
      mov     edx, [bmp_imagen_0+ecx*4]
      mov     [vector_images+ecx*4], dword edx
      inc     ecx
      cmp     ecx, 12     
      jne     .loadImageMatrix
  pop   edx
  
  stdcall   ClearBoard
  stdcall   DrawBoard
  ret
  
endp

; 0 1 2 3 4 5 6 7 8 9 10 11

proc CheckWin uses edx ecx
    push ecx edx
    mov ecx, dword 0
    .continue:
        push    ecx
        xor     edx, edx
        mov     edx, [matrix_game+ecx*4]
        cmp     edx, 11
        jne     .bypass
        invoke  MessageBox, 0, txtMessage, txtTitle, 0
        pop     ecx
        stdcall ClearBoard
        jmp     .finish_win_check
        .bypass:
        pop     ecx
        inc     ecx
        cmp     ecx, 16
        jne     .continue
    .finish_win_check:
    pop edx ecx
    ret
endp

proc GetAdyacents uses ecx ebx
    
    push    ecx ebx
    
    mov     [adyacent_north], 13
    mov     [adyacent_east], 13
    mov     [adyacent_west], 13
    mov     [adyacent_south], 13
    
    cmp     ecx, 0
    je      .set_0_0
    cmp     ecx, 1
    je      .set_0_1
    cmp     ecx, 2
    je      .set_0_2
    cmp     ecx, 3
    je      .set_0_3
    cmp     ecx, 4
    je      .set_1_0
    cmp     ecx, 5
    je      .set_1_1
    cmp     ecx, 6
    je      .set_1_2
    cmp     ecx, 7
    je      .set_1_3
    cmp     ecx, 8
    je      .set_2_0
    cmp     ecx, 9
    je      .set_2_1
    cmp     ecx, 10
    je      .set_2_2
    cmp     ecx, 11
    je      .set_2_3
    cmp     ecx, 12
    je      .set_3_0
    cmp     ecx, 13
    je      .set_3_1
    cmp     ecx, 14
    je      .set_3_2
    cmp     ecx, 15
    je      .set_3_3
    
    
    .set_0_0:
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx
    jmp  .finish_get_adyacent
    .set_0_1:
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx    
    jmp  .finish_get_adyacent
    .set_0_2:
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx    
    jmp  .finish_get_adyacent
    .set_0_3:
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx
    jmp  .finish_get_adyacent
    .set_1_0:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx
    jmp  .finish_get_adyacent
    .set_1_1:    
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx
    jmp  .finish_get_adyacent
    .set_1_2:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx    
    jmp  .finish_get_adyacent
    .set_1_3:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx
    jmp  .finish_get_adyacent
    .set_2_0:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx    
    jmp  .finish_get_adyacent
    .set_2_1:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx    
    jmp  .finish_get_adyacent
    .set_2_2:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx   
    jmp  .finish_get_adyacent
    .set_2_3:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx
    mov     ebx, [matrix_game+(ecx+4)*4]
    mov     [adyacent_south], ebx    
    jmp  .finish_get_adyacent
    .set_3_0:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx  
    jmp  .finish_get_adyacent
    .set_3_1:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx 
    jmp  .finish_get_adyacent
    .set_3_2:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx+1)*4]
    mov     [adyacent_east], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx     
    jmp  .finish_get_adyacent
    .set_3_3:
    mov     ebx, [matrix_game+(ecx-4)*4]
    mov     [adyacent_north], ebx
    mov     ebx, [matrix_game+(ecx-1)*4]
    mov     [adyacent_west], ebx  
    jmp  .finish_get_adyacent
    
    .finish_get_adyacent:
    pop     ebx ecx
    ret 

endp

proc CheckLose uses edx ecx
    push    ecx edx
    mov     ecx, 0
    mov     [bool_gamelost], 1
    .continue_check:
        xor     edx, edx
        mov     edx, [matrix_game+ecx*4]
        stdcall GetAdyacents
        cmp     edx, 0
        je      .make_bool_false
        cmp     edx, [adyacent_north]
        je      .make_bool_false
        cmp     edx, [adyacent_east]
        je      .make_bool_false
        cmp     edx, [adyacent_west]
        je      .make_bool_false
        cmp     edx, [adyacent_south]
        je      .make_bool_false
        
        inc     ecx
        cmp     ecx, 16
        jne     .continue_check
        jmp     .finish_lose_check              
        
    .make_bool_false:
    mov     [bool_gamelost], 0
    .finish_lose_check:
    
    cmp     [bool_gamelost], 1
    jne     .bypass_message
    invoke  MessageBox, 0, txtMessageSad, txtTitleSad, 0
    stdcall ClearBoard
    stdcall DrawBoard
    .bypass_message:
    pop     edx ecx
    ret
endp

proc DrawBoard uses edx ecx
  push  ecx edx
  mov   ecx, dword 0
  .drawButtons:
    push    ecx
    xor     edx, edx
    mov     edx, [matrix_game+ecx*4]
    invoke  SendMessage,[vector_buttons+ecx*4],BM_SETIMAGE,0,[vector_images+edx*4]
    pop     ecx
    inc     ecx
    cmp     ecx, 16     
    jne     .drawButtons
  .exit_draw_board:
  pop   edx ecx  
  ret
endp

proc ClearBoard uses edi ecx
  ; clears the matrix
        push  ecx edi
	lea edi, [matrix_game]
	xor ecx, ecx
  .CLEAR:

	mov [edi+ecx*4], dword 0
	inc ecx
	cmp ecx, 16
	jl .CLEAR        
        pop   edi ecx
	ret
endp

proc ClearChecks uses edi ecx
  ; clears the matrix
        push  ecx edi
	lea edi, [vector_checks]
	xor ecx, ecx
  .CLEAR:

	mov [edi+ecx*4], dword 0
	inc ecx
	cmp ecx, 16
	jl .CLEAR        
        pop   edi ecx
	ret
endp

proc    GetRandom uses esi edx
; gets a random value from 0 to 8
; leaves the randomNum stored in varible randomNum.
        push    esi
        rdtsc
        cdq
        
        mov     esi, 8        
        idiv    esi        
        cmp     edx, 0
        jnl     .after
        neg     edx        
        .after:      
        mov     [randomNum], edx
        pop     esi
        ret   
endp

proc    PlaceRandom uses ecx edx ebx
    push ecx edx ebx
    mov ecx, dword 0
    cmp [bool_validmove], 0
    je  .finish_random_placing
    .continue_placing:
        xor     edx, edx
        mov     edx, [matrix_game+ecx*4]
        cmp     edx, 0
        jne     .cant_place
        
        stdcall GetRandom             
        
        mov     ebx, [randomNum]
        mov     ebx, [vector_random+ebx*4]
        cmp     ebx, 0
        je      .cant_place        
        mov     [matrix_game+ecx*4], ebx
        jmp     .finish_random_placing       
        .cant_place:
        inc     ecx
        cmp     ecx, 16
        jne     .continue_placing
    .finish_random_placing:
    pop ebx edx ecx
    ret
endp

section '.bss' data readable writeable
  hInstance       DD  ?
  hFont10         DD  ?

  hlc_tme         TRACKMOUSEEVENT
  hlc_ps          PAINTSTRUCT
  hlc_hdc         DD  ?
  hlc_strlen      DD  ?
  hlc_prc         RECT
  hlc_color       DD  ?
  hlc_pt          POINT
  hlc_text        rb 2048
  hlc_pSubject    rd  1
  hlc_wcx         WNDCLASSEX

  CommandLine      rd 1
  wHandle          rd 1
 
  vector_images    rd 12  
 
  matrix_game      rd 16
  
  vector_checks    rd 16
     
  vector_buttons   rd 16     
      
  bmp_imagen_0     rd 1
  bmp_imagen_2     rd 1
  bmp_imagen_4     rd 1
  bmp_imagen_8     rd 1
  bmp_imagen_16    rd 1
  bmp_imagen_32    rd 1
  bmp_imagen_64    rd 1
  bmp_imagen_128   rd 1
  bmp_imagen_256   rd 1
  bmp_imagen_512   rd 1
  bmp_imagen_1024  rd 1
  bmp_imagen_2048  rd 1
  
  hIcoInfo         rd 1
  hIcoUExit        rd 1
  hIcoDExit        rd 1
  hCursor          rd 1
  hhWnd            rd 1
  mbp1             MSGBOXPARAMS
  msg              MSG

section '.data' data readable writeable
  Arial_Black_10  LOGFONT  -13,0,0,0,400,0,0,0,0,3,2,1,34,"Arial Black"
  NombreClase      TCHAR    'SimpleWinClass',0
  DlgName          TCHAR    'dlgInformation',0
  TituloVentana      TCHAR    '2048 GAME',0
  MsgError         TCHAR    'Carga inicial fallida.',0
  wc               WNDCLASS 0,WndProc,0,0,NULL,NULL,NULL,cdColFondo,NULL,NombreClase
  MsgGpbBmp             db "Board",0
  btn_up_message        db "UP", 0
  btn_left_message      db "LEFT", 0
  btn_right_message     db "RIGHT", 0
  btn_down_message      db "DOWN", 0
  
  txtTitle              db      'Congratulations!',0
  txtMessage            db      'You win!',0
  
  txtTitleSad           db      'Almost there!',0
  txtMessageSad         db      'You lost!',0
  
  randomNum       dd    0
  
  btn_start_message     db "NEW GAME", 0
  
  bool_gamelost    dd 0
  bool_validmove   dd 0    
  vector_random    dd 0, 0, 0, 0, 0, 1, 1, 2
        
  adyacent_north   dd 13
  adyacent_east    dd 13
  adyacent_west    dd 13
  adyacent_south   dd 13 
                                                        
  lpBtnProc        dd 0
  lpfnbmpProc      dd 0
  lpfnbmpProcBmp   dd 0
  lpBtnProcIco     dd 0
  ClaseBoton       db "BUTTON", 0
  ClaseTexto       db "STATIC", 0
  ClaseEdit        db "EDIT", 0
  vbButActiv       db 1 ; -1:true, 0:false (active/inactive), en principio está activado

  gpbBmp    DatosControl ClaseBoton, MsgGpbBmp,\
            WS_CHILD + WS_VISIBLE + BS_GROUPBOX, 40, 5, windowWidth-95, windowHeight-50, cdID_OBJETO,NULL

   btn_0_0 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 10, 20, 150, 150, cdID_OBJETO+2,NULL
   btn_0_1 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 160, 20, 150, 150, cdID_OBJETO+3,NULL
   btn_0_2 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 310, 20, 150, 150, cdID_OBJETO+4,NULL
   btn_0_3 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 460, 20, 150, 150, cdID_OBJETO+5,NULL



   btn_1_0 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 10, 170, 150, 150, cdID_OBJETO+6,NULL
   btn_1_1 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 160, 170, 150, 150, cdID_OBJETO+7,NULL
   btn_1_2 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 310, 170, 150, 150, cdID_OBJETO+8,NULL
   btn_1_3 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 460, 170, 150, 150, cdID_OBJETO+9,NULL


   btn_2_0 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 10, 320, 150, 150, cdID_OBJETO+10,NULL
   btn_2_1 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 160, 320, 150, 150, cdID_OBJETO+11,NULL
   btn_2_2 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 310, 320, 150, 150, cdID_OBJETO+12,NULL
   btn_2_3 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 460, 320, 150, 150, cdID_OBJETO+13,NULL


   btn_3_0 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 10, 470, 150, 150, cdID_OBJETO+14,NULL
   btn_3_1 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 160, 470, 150, 150, cdID_OBJETO+15,NULL
   btn_3_2 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 310, 470, 150, 150, cdID_OBJETO+16,NULL
   btn_3_3 DatosControl ClaseBoton, "",\
            WS_CHILD + WS_VISIBLE + BS_BITMAP + WS_TABSTOP, 460, 470, 150, 150, cdID_OBJETO+17,NULL


   btn_up  DatosControl ClaseBoton, btn_up_message,\
            WS_CHILD + WS_VISIBLE + BS_DEFPUSHBUTTON + WS_TABSTOP, 315, 630, 65, 30, cdID_OBJETO+18,NULL
            
   btn_left  DatosControl ClaseBoton, btn_left_message,\
            WS_CHILD + WS_VISIBLE + BS_DEFPUSHBUTTON + WS_TABSTOP, 250, 660, 65, 30, cdID_OBJETO+19,NULL
            
   btn_right  DatosControl ClaseBoton, btn_right_message,\
            WS_CHILD + WS_VISIBLE + BS_DEFPUSHBUTTON + WS_TABSTOP, 380, 660, 65, 30, cdID_OBJETO+20,NULL
            
   btn_down  DatosControl ClaseBoton, btn_down_message,\
            WS_CHILD + WS_VISIBLE + BS_DEFPUSHBUTTON + WS_TABSTOP, 315, 690, 65, 30, cdID_OBJETO+21,NULL
            
   btn_start  DatosControl ClaseBoton, btn_start_message,\
            WS_CHILD + WS_VISIBLE + BS_DEFPUSHBUTTON + WS_TABSTOP, 50, 660, 90, 30, cdID_OBJETO+22,NULL

section '.idata' import data readable writeable
  library kernel32,'KERNEL32.DLL',\ 
          user32,  'USER32.DLL',\
          gdi32,   'GDI32.DLL',\
          shell32, 'SHELL32.DLL',\
          comctl32,'COMCTL32.DLL',\
          msvcrt,   'msvcrt.dll'
          
  include 'api\kernel32.inc'           ; KERNEL32 API calls
  include 'api\user32.inc'             ; USER32 API calls
  include 'api\gdi32.inc'     
  include 'api\shell32.inc'     
  include 'api\comctl32.inc'
       
    import msvcrt, printf, 'printf'
    import    GDI32,\
              CreateFont,      'CreateFontA',\
              SelectObject,    'SelectObjectA',\
              DeleteObject,    'DeleteObjectA'

section '.rsrc' resource data readable

  ; resource directory

  directory RT_BITMAP,appBmp,\
            RT_VERSION,versions

  resource appBmp,\
       cdimagen_0,LANG_NEUTRAL,imagen_0,\
       cdimagen_2,LANG_NEUTRAL,imagen_2,\
       cdimagen_4,LANG_NEUTRAL,imagen_4,\
       cdimagen_8,LANG_NEUTRAL,imagen_8,\
       cdimagen_16,LANG_NEUTRAL,imagen_16,\
       cdimagen_32,LANG_NEUTRAL,imagen_32,\
       cdimagen_64,LANG_NEUTRAL,imagen_64,\
       cdimagen_128,LANG_NEUTRAL,imagen_128,\
       cdimagen_256,LANG_NEUTRAL,imagen_256,\
       cdimagen_512,LANG_NEUTRAL,imagen_512,\
       cdimagen_1024,LANG_NEUTRAL,imagen_1024,\
       cdimagen_2048,LANG_NEUTRAL,imagen_2048

  resource versions,\
       1,LANG_NEUTRAL,version

  bitmap imagen_0,      'C:\Ensambla_TP2\2048_assets\0.bmp'
  bitmap imagen_2,      'C:\Ensambla_TP2\2048_assets\2.bmp'
  bitmap imagen_4,      'C:\Ensambla_TP2\2048_assets\4.bmp'
  bitmap imagen_8,      'C:\Ensambla_TP2\2048_assets\8.bmp'
  bitmap imagen_16,     'C:\Ensambla_TP2\2048_assets\16.bmp'
  bitmap imagen_32,     'C:\Ensambla_TP2\2048_assets\32.bmp'
  bitmap imagen_64,     'C:\Ensambla_TP2\2048_assets\64.bmp'
  bitmap imagen_128,    'C:\Ensambla_TP2\2048_assets\128.bmp'
  bitmap imagen_256,    'C:\Ensambla_TP2\2048_assets\256.bmp'
  bitmap imagen_512,    'C:\Ensambla_TP2\2048_assets\512.bmp'
  bitmap imagen_1024,   'C:\Ensambla_TP2\2048_assets\1024.bmp'
  bitmap imagen_2048,   'C:\Ensambla_TP2\2048_assets\2048.bmp'


  versioninfo version,VOS__WINDOWS32,VFT_APP,VFT2_UNKNOWN,LANG_SPANISH+SUBLANG_DEFAULT,0,\
          'FileDescription',  '2048 Game',\
          'LegalCopyright',   'All rights reserved.',\
          'FileVersion',      '1.0.0.0',\
          'ProductVersion',   '1.0.0.0',\
          'OriginalFilename', '2048.EXE'
