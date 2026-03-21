#include <iostream>

# if 0
int main() {
    std::cout << "CI/CD Demo Running!" << std::endl;
    return 0;
}
# else

int main() {
    int *p = nullptr;
    *p = 10;   // ❌ null pointer dereference
    return 0;
}

# endif
