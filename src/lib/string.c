int strcmp(const char* str1, const char* str2) {
    while (*str1 && (*str1 == *str2)) { // Loop while str1 has not ended
                                        // and while str1 is the same as str2
        str1++;
        str2++;
    }
    // If 0, they are equal
    return *str1 - *str2;
}

int strlen(const char* str) {
    int len = 0; // Length counter
    while (*str != '\0') { // Check if current character is the null terminator
        len++; // Increment length
        str++; // Continue till null terminator
    }
    return len; // Return length
}