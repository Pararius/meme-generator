<?php

declare(strict_types=1);

namespace Tests\Unit\App\Entity;

use App\Entity\Meme;
use PHPUnit\Framework\TestCase;

class MemeTest extends TestCase
{
    private const ID = '01acf4b4-2160-4a46-b904-7043c9bfd97a';
    private const TEXT = 'text';

    /**
     * @test
     */
    public function test_construct(): void
    {
        $meme = new Meme();
        $meme->setId(self::ID);
        $meme->setText(self::TEXT);

        self::AssertSame(self::ID, $meme->getId());
        self::AssertSame(self::TEXT, $meme->getText());
    }
}
