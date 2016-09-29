/*
 * =====================================================================================
 *
 *       Filename:  main.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2016年08月16日 15时57分37秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  袁致远 (mn), yuanzhiyuan@nfschina.com
 *        Company:  中科方德
 *
 * =====================================================================================
 */

#include <stdio.h>
#include "add.h"
#include "sub.h"
int main(void){
    int a=10,b=12;
    float x=1.23456,y=9.87654321;
    
    printf("int a+b is : %d\n", add_int(a,b));
    printf("int a-b is : %d\n", sub_int(a,b));
    printf("float a-b is : %d\n", add_float(a,b));
    printf("float a-b is : %d\n", sub_float(a,b));
}
