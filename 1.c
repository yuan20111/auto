/*
 * =====================================================================================
 *
 *       Filename:  1.c
 *
 *    Description:  
 *
 *        Version:  1.0
 *        Created:  2016年09月27日 13时57分37秒
 *       Revision:  none
 *       Compiler:  gcc
 *
 *         Author:  袁致远 (mn), yuanzhiyuan@nfschina.com
 *        Company:  中科方德
 *
 * =====================================================================================
 */

#define _BSD_SOURCE
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>

int
main(int argc, char *argv[])
{
    struct in_addr addr;

    if (argc != 2) {
        fprintf(stderr, "%s <dotted-address>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    if (inet_aton(argv[1], &addr) == 0) {
        fprintf(stderr, "Invalid address\n");
        exit(EXIT_FAILURE);
    }

    printf("%s\n", inet_ntoa(addr));
    exit(EXIT_SUCCESS);
}


