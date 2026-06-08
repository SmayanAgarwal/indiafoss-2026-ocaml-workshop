/* Heartbleed in miniature, structured like the real OpenSSL handler.
 * receive_heartbeat() reads a request buffer, interprets the first
 * byte as the heartbeat type, the next two as a big-endian payload
 * length, and echoes `payload_len` bytes back.
 *
 * The bug: it trusts the attacker's length field and never checks it
 * against the bytes actually received, so memcpy reads past the
 * request into adjacent server memory and ships whatever is there
 * back to the attacker.
 *
 *   cc -o heartbleed_mini heartbleed_mini.c && ./heartbleed_mini
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define n2s(p) (((p)[0] << 8) | (p)[1])   /* read a 2-byte big-endian length */

/* The server side. The incoming request lands at the front of the
 * server's memory; other live data (here, a secret) sits nearby in
 * the same region. The memset is only so the demo is reproducible:
 * real server memory holds whatever was there, not zeros. */
unsigned char *receive_heartbeat(unsigned char *request, int received,
                                 int *resp_len) {
    unsigned char *server_mem = malloc(64);
    memset(server_mem, 0, 64);
    memcpy(server_mem, request, received);              /* the request, as received */
    strcpy((char *)server_mem + 16, "TLS-PRIVATE-KEY"); /* server's secret, nearby */

    int payload_len = n2s(server_mem + 1);     /* attacker-controlled, 0..65535 */
    unsigned char *payload = server_mem + 3;   /* the payload starts here */

    /* THE BUG: payload_len is never checked against `received`. The
     * real OpenSSL fix is one line:
     *     if (1 + 2 + payload_len > received) return NULL;          */
    (void)received;

    unsigned char *response = malloc(payload_len);
    memcpy(response, payload, payload_len);   /* reads past the request into server_mem */
    *resp_len = payload_len;
    return response;
}

int main(void) {
    /* The attacker sends a tiny request: a type byte, a claimed
     * length of 48, and a single real payload byte. There is no
     * secret here; the secret lives on the server. */
    unsigned char request[4];
    request[0] = 1;                   /* heartbeat request type            */
    request[1] = 0; request[2] = 48;  /* claimed payload length = 48       */
    request[3] = 'h';                 /* the 1 payload byte really sent    */

    int received = 4;                 /* type + length + 1 payload byte    */
    int resp_len;
    unsigned char *response = receive_heartbeat(request, received, &resp_len);

    printf("request carried %d real payload byte, claimed %d\n",
           received - 3, resp_len);
    printf("echoed back: ");
    for (int i = 0; i < resp_len; i++) {
        unsigned char c = response[i];
        putchar(c >= 32 && c < 127 ? c : '.');
    }
    putchar('\n');
    return 0;
}
