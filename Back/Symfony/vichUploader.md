# vichUploader

Ce bundle de Symfony permet de gérer la partie sélection d’un fichier, upload sur le serveur et enregistrement en base de données.

### 1. 📦 Installer le bundle

```bash
composer require vich/uploader-bundle

```

---

### 2. ⚙️ Configurer le bundle

Dans `config/packages/vich_uploader.yaml` :

```yaml
vich_uploader:
    db_driver: orm

    mappings:
        product_image:
            uri_prefix: /uploads/products
            upload_destination: '%kernel.project_dir%/public/uploads/products'
            namer: Vich\UploaderBundle\Naming\SmartUniqueNamer

```

---

### 3. 🧱 Créer (ou modifier) l'entité `Product`

```php
// src/Entity/Product.php

use Doctrine\ORM\Mapping as ORM;
use Vich\UploaderBundle\Mapping\Annotation as Vich;
use Symfony\Component\HttpFoundation\File\File;
use Symfony\Component\Validator\Constraints as Assert;

#[ORM\Entity]
#[Vich\Uploadable]
class Product
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column(type: 'integer')]
    private $id;

    #[ORM\Column()]
    private $imageName;

    #[Vich\UploadableField(mapping: 'product_image', fileNameProperty: 'imageName')]
    private ?File $imageFile = null;

    #[ORM\Column(type: 'datetime')]
    private \DateTimeInterface $updatedAt;

    public function setImageFile(?File $imageFile = null): void
    {
        $this->imageFile = $imageFile;

        if ($imageFile !== null) {
            $this->updatedAt = new \DateTimeImmutable();
        }
    }

    public function getImageFile(): ?File
    {
        return $this->imageFile;
    }

    public function getImageName(): ?string
    {
        return $this->imageName;
    }

    public function setImageName(?string $imageName): void
    {
        $this->imageName = $imageName;
    }

    // Autres getters/setters...
}

```

---

### 4. 📋 Créer un formulaire pour le produit

```powershell
symfony console make:Form Product
```

```php
// src/Form/ProductType.php

use Symfony\Component\Form\AbstractType;
use Symfony\Component\Form\FormBuilderInterface;
use Symfony\Component\Form\Extension\Core\Type\FileType;
use Symfony\Component\OptionsResolver\OptionsResolver;
use Symfony\Component\Validator\Constraints\File;
use App\Entity\Product;

class ProductType extends AbstractType
{
    public function buildForm(FormBuilderInterface $builder, array $options)
    {
        $builder
            // Ajoutez vos autres champs ici
            ->add('imageFile', FileType::class);
    }

    public function configureOptions(OptionsResolver $resolver)
    {
        $resolver->setDefaults([
            'data_class' => Product::class,
        ]);
    }
}

```

---

### 5. 🎮 Gérer le formulaire dans le contrôleur

```php
// src/Controller/ProductController.php

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use App\Entity\Product;
use App\Form\ProductType;
use Doctrine\ORM\EntityManagerInterface;

public function new(Request $request, EntityManagerInterface $em): Response
{
    $product = new Product();
    $form = $this->createForm(ProductType::class, $product);
    $form->handleRequest($request);

    if ($form->isSubmitted() && $form->isValid()) {
        $em->persist($product);
        $em->flush();

        return $this->redirectToRoute('product_index');
    }

    return $this->render('product/new.html.twig', [
        'form' => $form->createView(),
    ]);
}

```

---

### 6. 🖼️ Afficher l’image dans le template Twig

```
{% if product.imageName %}
    <img src="{{ asset('uploads/products/' ~ product.imageName) }}" alt="Image du produit" />
{% endif %}

```

---