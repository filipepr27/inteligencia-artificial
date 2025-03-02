import signal
from random import randint
import matplotlib.pyplot as plt
import torch
import torch.nn as nn
import torch.nn.functional as F
from torchvision.datasets import ImageFolder
from torchvision.transforms import v2
from torchvision.transforms import ToTensor, Normalize, Resize
from torch.utils.data.dataloader import DataLoader
from torch.utils.data import Subset
import torch.optim as optim
from sklearn.model_selection import train_test_split
import multiprocessing

# Configuração para uso da GPU
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
torch.backends.cudnn.benchmark = True

PARAR = False
def handler(signum, frame):
    global PARAR
    print("\b\n[Ctrl-C pressionado. Parando o treinamento...]")
    PARAR = True

signal.signal(signal.SIGINT, handler)

# Rede Neural Convolucional
class Net(nn.Module):
    def __init__(self, numero_de_classes=3):
        super().__init__()
        self.conv1 = nn.Conv2d(3, 6, 5)
        self.pool = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(6, 16, 5)
        self.conv3 = nn.Conv2d(16, 32, 3)  # Nova camada convolucional
        # Ajustando o tamanho da camada totalmente conectada para o novo tamanho de imagem
        self.fc1 = nn.Linear(32 * 13 * 13, 120)  # Para imagens de 128x128 após 3 camadas convolucionais
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, numero_de_classes)

    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        
        # Passando pela nova camada convolucional
        x = self.pool(F.relu(self.conv3(x)))
        
        x = torch.flatten(x, 1)  # Flatten all dimensions except batch
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        x = self.fc3(x)
        return x

def main():
    # Definindo o tamanho padrão para todas as imagens
    image_size = 128
    
    # Transformações para redimensionar todas as imagens para o mesmo tamanho
    transform = v2.Compose([
        v2.Resize((image_size, image_size)),  # Redimensiona para tamanho padrão
        v2.ToTensor(),
        v2.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])  # Normalização mais comum para ImageNet
    ])
    
    # Carregando o dataset a partir de uma única pasta (substitua o caminho conforme necessário)
    train_data = ImageFolder('./inst/train', transform=transform)
    test_data = ImageFolder('./inst/test', transform=transform)
    print(f'Classes do train_data: {train_data.classes}')
    print(f'Tamanho da figura: {train_data[0][0].shape}')

    # Exemplo de visualização de uma imagem
    def show_example(img, label):
        plt.imshow(img.permute(1, 2, 0))
        plt.title(f'Classe: {train_data.classes[label]} ({label})')
        plt.show()

    show_example(*train_data[randint(0, len(train_data))])

    # DataLoader com otimizações para GPU
    batch_size = 32
    # Reduz o número de workers para maior estabilidade
    num_workers = 2
    trainloader = DataLoader(train_data, batch_size=batch_size, shuffle=True, 
                             num_workers=num_workers, pin_memory=True)
    testloader = DataLoader(test_data, batch_size=batch_size, 
                           num_workers=num_workers, pin_memory=True)

    # Definindo a função de perda e otimizador
    criterion = nn.CrossEntropyLoss()
    max_epocas = 30

    # Lista para armazenar as acurácias dos treinamentos
    acuracias = []
    num_runs = 3

    for run in range(num_runs):
        print(f'\n=== Execução {run+1}/{num_runs} ===')

        net = Net()
        print(net)
        
        # Instancia um novo modelo e otimizador para cada execução
        criterion = nn.CrossEntropyLoss()
        optimizer = optim.SGD(net.parameters(), lr=0.001, momentum=0.9)
                
        # Treinamento
        for epoch in range(max_epocas):
            print(f'Treinando época {epoch+1}:')
            total_loss, running_loss = 0.0, 0.0
            for i, data in enumerate(trainloader, 0):
                inputs, labels = data
                optimizer.zero_grad()
                outputs = net(inputs)
                loss = criterion(outputs, labels)
                loss.backward()
                optimizer.step()

                total_loss += loss.item()
                running_loss += loss.item()
                if i % 100 == 99:
                    print(f'[{epoch+1}, {i+1:5d}] loss: {running_loss/100:.3f}')
                    running_loss = 0.0
            print(f'Loss: {total_loss/len(trainloader):.3f}')
            if PARAR: break

        print('Treinamento concluído para essa execução.')

        print('Testando:')
        correct = 0
        total = 0
        with torch.no_grad():
            for data in testloader:
                try:
                    images, labels = data
                    outputs = net(images)
                    _, predicted = torch.max(outputs.data, 1)
                    total += labels.size(0)
                    correct += (predicted == labels).sum().item()
                except Exception as e:
                    print(f"Erro no teste: {str(e)}")
                    continue
        
        if total > 0:  # Evitar divisão por zero
            acc = 100 * correct / total
            print(f'Acurácia da execução {run+1}: {acc:.2f} %')
            acuracias.append(acc)
        else:
            print(f'Não foi possível calcular a acurácia para a execução {run+1}')

    if acuracias:  # Verificar se há resultados para plotar
        # Plotando o gráfico boxplot com as acurácias
        plt.boxplot(acuracias)
        plt.title('Boxplot das Acurácias dos Treinamentos')
        plt.ylabel('Acurácia (%)')
        plt.show()
    else:
        print("Não há acurácias para plotar.")

if __name__ == '__main__':
    # Importante para o multiprocessing em Windows
    multiprocessing.freeze_support()
    # Importação de numpy é necessária para visualizar imagens
    import numpy as np
    main()