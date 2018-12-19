<?php

namespace App\Controller;

use App\Entity\Meme;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\Cache\Simple\AbstractCache;
use Symfony\Component\Cache\Simple\RedisCache;
use Symfony\Component\Form\Extension\Core\Type\SubmitType;
use Symfony\Component\Form\Extension\Core\Type\TextType;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Treinetic\ImageArtist\lib\Image;
use Treinetic\ImageArtist\lib\Text\Color;
use Treinetic\ImageArtist\lib\Text\Font;
use Treinetic\ImageArtist\lib\Text\TextBox;

class MemeController extends AbstractController
{
    /**
     * @var AbstractCache
     */
    private $cache;

    /**
     * @var \Redis
     */
    private $redis;

    public function __construct()
    {
        $this->redis = new \Redis();
        $this->redis->connect(getenv('REDIS_HOST'));
        $this->cache = new RedisCache($this->redis);
    }

    /**
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\RedirectResponse|Response
     * @throws \Psr\SimpleCache\InvalidArgumentException
     */
    public function new(Request $request)
    {
        $meme = new Meme();

        $form = $this->createFormBuilder($meme)
            ->add('text', TextType::class)
            ->add('save', SubmitType::class, array('label' => 'Create Meme'))
            ->getForm();

        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $data = $form->getData();
            $id = uniqid();
            $meme->setId($id);
            $meme->setText($data->getText());

            $this->cache->set($id, $data->getText());

            return $this->redirectToRoute('view', ['id' => $id]);
        }

        return $this->render('meme/new.html.twig', ['form' => $form->createView()]);
    }

    /**
     * @return Response
     */
    public function index()
    {
        $memes = $this->redis->keys('*');

        return $this->render('meme/index.html.twig', ['memes' => $memes]);
    }

    /**
     * @param string $id
     * @return mixed
     * @throws \Psr\SimpleCache\InvalidArgumentException
     */
    public function view(string $id)
    {
        if ($this->cache->has($id)) {
            $image = new Image('img/source.jpg');
            $textBox = new TextBox(300, 450);
            $textBox->setColor(Color::getColor(Color::$WHITE));
            $textBox->setFont(Font::getFont(Font::$NOTOSERIF_BOLD));
            $textBox->setSize(30);
            $textBox->setMargin(2);
            $textBox->setText(strtoupper($this->cache->get($id)));
            $image->setTextBox($textBox, 300, 20);

            return $this->render('meme/view.html.twig', ['image' => $image->getDataURI()]);
        } else {
            return new Response('No such meme', 404);
        }
    }
}
